module Helpers exposing (..)

import Dict exposing (Dict)
import FamilyTree.Scalar exposing (Id(..))
import List.Extra as LE
import Model exposing (Bounds, Family, Msg, Person)
import TypedSvg.Core as SC


getOffset : Dict Int Bounds -> Dict Int Float -> Float
getOffset childrenBoundsByLevel previousBoundsByLevel =
    let
        overlapByLevel =
            childrenBoundsByLevel
                |> Dict.foldr
                    (\l bounds overlapAcc ->
                        let
                            maybeMaxX2ForLevel =
                                Dict.get l previousBoundsByLevel
                        in
                        case maybeMaxX2ForLevel of
                            Just maxX2 ->
                                overlapAcc
                                    |> Dict.insert l
                                        (if maxX2 > bounds.x1 then
                                            maxX2 - bounds.x1 + Model.widthBetweenSiblings

                                         else
                                            0
                                        )

                            Nothing ->
                                overlapAcc
                    )
                    Dict.empty
    in
    overlapByLevel
        |> Dict.values
        |> List.maximum
        |> Maybe.withDefault 0


getAbsolutePosition : Float -> List Person -> Int -> Float
getAbsolutePosition childrenOrigin children idx =
    childrenOrigin
        + ((Model.personWidth + Model.widthBetweenSiblings) * toFloat idx)
        + ((Model.personWidth + Model.widthBetweenSpouses) * toFloat (getNumberOfPreviousSiblingsSpouses children idx))


getChildrenBounds : Float -> Family -> Person -> Dict Int Bounds
getChildrenBounds parentX1 ({ tree, relationships } as family) currentPerson =
    let
        descendants : Dict Int (List Person)
        descendants =
            getPersonDescendants 0 family currentPerson Dict.empty

        parentsCenter =
            parentX1 + (Model.parentsWidth / 2)
    in
    descendants
        |> Dict.map
            (\_ siblings ->
                let
                    numberOfSiblings =
                        List.length siblings

                    numberOfSpouses =
                        -- the last spouse does not count
                        getNumberOfPreviousSiblingsSpouses siblings (numberOfSiblings - 1)

                    width =
                        (toFloat numberOfSiblings * Model.personWidth)
                            + (toFloat (numberOfSiblings - 1) * Model.widthBetweenSiblings)
                            + (toFloat numberOfSpouses * (Model.personWidth + Model.widthBetweenSpouses))
                in
                { x1 = parentsCenter - (width / 2), x2 = parentsCenter + (width / 2) }
            )


getChildAtIndex : List Person -> Int -> List Id -> Maybe Person
getChildAtIndex tree index childrenIds =
    childrenIds
        |> LE.getAt index
        |> Maybe.andThen (getPersonFromId tree)


getNumberOfPreviousSiblingsSpouses : List Person -> Int -> Int
getNumberOfPreviousSiblingsSpouses children currentIndex =
    let
        indexesToLookUp =
            List.range 0 (currentIndex - 1)
    in
    indexesToLookUp
        |> List.foldl
            (\idx acc ->
                LE.getAt idx children
                    |> Maybe.map
                        (\person ->
                            if hasSpouse person then
                                acc + 1

                            else
                                acc
                        )
                    |> Maybe.withDefault acc
            )
            0


getPreviousSiblingsMaxX2ForEachLevel : Dict Int ( Float, SC.Svg Msg ) -> Float -> Family -> List Person -> Int -> Dict Int Float
getPreviousSiblingsMaxX2ForEachLevel positionAndViewChildrenAcc firstSiblingX1 family children currentIndex =
    let
        getPreviousSiblingBounds ix sib =
            Dict.get ix positionAndViewChildrenAcc
                |> Maybe.map Tuple.first
                |> Maybe.withDefault (getAbsolutePosition firstSiblingX1 children ix)
                |> (\pos -> getChildrenBounds pos family sib)
    in
    List.range 0 (currentIndex - 1)
        |> List.foldl
            (\idx maxX2ByLevelAcc ->
                LE.getAt idx children
                    |> Maybe.map
                        (\previousSibling ->
                            let
                                bounds =
                                    getPreviousSiblingBounds idx previousSibling
                            in
                            bounds
                                |> Dict.foldl
                                    (\l b bAcc ->
                                        bAcc
                                            |> Dict.update l (\maybeX2 -> max b.x2 (maybeX2 |> Maybe.withDefault 0) |> Just)
                                    )
                                    maxX2ByLevelAcc
                        )
                    |> Maybe.withDefault maxX2ByLevelAcc
            )
            Dict.empty


getPersonDescendants : Int -> Family -> Person -> Dict Int (List Person) -> Dict Int (List Person)
getPersonDescendants level ({ tree, relationships } as family) currentPerson currentDict =
    let
        addChildToDescendantsAcc child acc =
            acc
                |> Dict.update level (\maybeVal -> child :: (maybeVal |> Maybe.withDefault []) |> Just)
    in
    case currentPerson.relationship of
        Nothing ->
            currentDict

        Just relId ->
            relationships
                |> List.filter (.id >> (==) relId)
                |> List.head
                |> Maybe.map
                    (\{ children } ->
                        children
                            |> List.foldr
                                (\childId acc ->
                                    case getPersonFromId tree childId of
                                        Just child ->
                                            acc
                                                |> addChildToDescendantsAcc child
                                                |> getPersonDescendants (level + 1) family child

                                        Nothing ->
                                            acc
                                )
                                currentDict
                    )
                |> Maybe.withDefault currentDict


getSpouse : List Person -> Person -> Id -> Maybe Person
getSpouse tree person relId =
    tree
        |> List.filter (\p -> p.relationship == Just relId && p.firstName /= person.firstName && p.lastName /= person.lastName)
        |> List.head


hasSpouse : Person -> Bool
hasSpouse person =
    person.relationship /= Nothing


getPersonName : Person -> String
getPersonName person =
    person.firstName ++ " " ++ String.toUpper person.lastName


getPersonFromId : List Person -> Id -> Maybe Person
getPersonFromId tree id =
    tree
        |> List.filter (.id >> (==) id)
        |> List.head
