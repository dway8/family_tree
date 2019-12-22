module Main exposing (..)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Color
import Dict exposing (Dict)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Html exposing (Html)
import List.Extra as LE
import TypedSvg as Svg exposing (svg)
import TypedSvg.Attributes as SA
import TypedSvg.Attributes.InPx as InPx
import TypedSvg.Core as SC
import TypedSvg.Events as SE
import TypedSvg.Types exposing (Align(..), CoordinateSystem(..), Cursor(..), Fill(..), Length(..), MeetOrSlice(..), Scale(..))
import Url exposing (Url)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = always NoOp
        , onUrlChange = always NoOp
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


type alias Model =
    { tree : List Person
    , lastName : String
    , relationships : List Relationship
    }


type alias Person =
    { id : Id
    , firstName : String
    , lastName : String
    , sex : Sex
    , relationship : Maybe Id
    }


type alias Relationship =
    { id : Id
    , children : List Id
    }


type Sex
    = Male
    | Female


type alias Id =
    Int


type Msg
    = NoOp
    | SelectedLastName String


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { tree =
            [ { id = 1
              , firstName = "Vianney"
              , lastName = "Manière"
              , sex = Male
              , relationship = Just 1
              }
            , { id = 2
              , firstName = "Blandine"
              , lastName = "Jantet"
              , sex = Female
              , relationship = Just 2
              }
            , { id = 3
              , firstName = "Olivier"
              , lastName = "Manière"
              , sex = Male
              , relationship = Just 2
              }
            , { id = 4
              , firstName = "Orlane"
              , lastName = "Félix"
              , sex = Female
              , relationship = Just 1
              }
            , { id = 5
              , firstName = "Felix"
              , lastName = "Manière"
              , sex = Male
              , relationship = Nothing
              }
            , { id = 6
              , firstName = "Timothée"
              , lastName = "Manière"
              , sex = Male
              , relationship = Nothing
              }
            , { id = 7
              , firstName = "Alice"
              , lastName = "Moulin"
              , sex = Female
              , relationship = Just 3
              }
            , { id = 8
              , firstName = "Georges"
              , lastName = "Jantet"
              , sex = Male
              , relationship = Just 3
              }
            , { id = 9
              , firstName = "Diane"
              , lastName = "Manière"
              , sex = Female
              , relationship = Nothing
              }
            , { id = 10
              , firstName = "Médéric"
              , lastName = "Manière"
              , sex = Male
              , relationship = Nothing
              }
            , { id = 11
              , firstName = "Dominique"
              , lastName = "Manière"
              , sex = Male
              , relationship = Just 4
              }
            , { id = 13
              , firstName = "Sophie"
              , lastName = "Manière"
              , sex = Female
              , relationship = Nothing
              }
            , { id = 14
              , firstName = "Nicole"
              , lastName = "de Kernafflen de Kergos"
              , sex = Female
              , relationship = Just 5
              }
            , { id = 15
              , firstName = "Paul-Henry"
              , lastName = "Manière"
              , sex = Female
              , relationship = Just 5
              }
            , { id = 16
              , firstName = "Martine"
              , lastName = "Jantet"
              , sex = Female
              , relationship = Nothing
              }
            , { id = 17
              , firstName = "Bruno"
              , lastName = "Jantet"
              , sex = Male
              , relationship = Just 6
              }
            , { id = 18
              , firstName = "Melchior"
              , lastName = "Manière"
              , sex = Male
              , relationship = Nothing
              }
            , { id = 19
              , firstName = "Chantal"
              , lastName = "de Saint-Mars"
              , sex = Female
              , relationship = Just 4
              }
            , { id = 20
              , firstName = "Pierre"
              , lastName = "Manière"
              , sex = Male
              , relationship = Nothing
              }
            , { id = 21
              , firstName = "Paul-Marie"
              , lastName = "Manière"
              , sex = Male
              , relationship = Nothing
              }
            , { id = 22
              , firstName = "Edmée"
              , lastName = "Manière"
              , sex = Female
              , relationship = Nothing
              }
            , { id = 23
              , firstName = "Isabelle"
              , lastName = "Giraud"
              , sex = Female
              , relationship = Just 6
              }
            , { id = 24
              , firstName = "Benoît"
              , lastName = "Jantet"
              , sex = Male
              , relationship = Nothing
              }
            , { id = 25
              , firstName = "Henry"
              , lastName = "Jantet"
              , sex = Male
              , relationship = Nothing
              }
            , { id = 26
              , firstName = "Constant"
              , lastName = "Jantet"
              , sex = Male
              , relationship = Nothing
              }
            , { id = 27
              , firstName = "Roseline"
              , lastName = "Manière"
              , sex = Female
              , relationship = Nothing
              }
            ]
      , relationships =
            [ { id = 1, children = [ 5, 6 ] }
            , { id = 2, children = [ 1, 9, 10, 18 ] }
            , { id = 3, children = [ 16, 17, 2 ] }
            , { id = 4, children = [ 20, 21, 22 ] }
            , { id = 5, children = [ 11, 27, 3, 13 ] }
            , { id = 6, children = [ 24, 25, 26 ] }
            ]
      , lastName = "Manière"
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SelectedLastName lastName ->
            ( { model | lastName = lastName }, Cmd.none )


view : Model -> Document Msg
view model =
    { title = "My app"
    , body =
        [ viewTree model ]
    }


viewTree : Model -> Html Msg
viewTree { tree, relationships, lastName } =
    let
        allChildrenIds =
            relationships |> List.concatMap .children

        firstAncestor =
            tree
                |> List.filter
                    (\person ->
                        (person.lastName == lastName)
                            && (not <| List.member person.id allChildrenIds)
                    )
                |> List.head
    in
    layout
        [ Font.family
            [ Font.external
                { name = "Roboto"
                , url = "https://fonts.googleapis.com/css?family=Roboto:300,300italic,400,400italic,700"
                }
            ]
        , height fill
        , width fill
        , Background.color (rgb255 250 250 250)
        ]
    <|
        el [ width fill, height fill ] <|
            html <|
                Svg.svg
                    [ SA.width <| Px 1900
                    , SA.height <| Px 600
                    , SA.viewBox 0 0 1900 600
                    , SA.preserveAspectRatio (Align ScaleMin ScaleMin) Meet
                    ]
                    (case firstAncestor of
                        Nothing ->
                            []

                        Just ancestor ->
                            [ viewPersonWithDescendants 0 600 100 tree relationships ancestor ]
                    )


viewPersonWithDescendants : Int -> Float -> Float -> List Person -> List Relationship -> Person -> SC.Svg Msg
viewPersonWithDescendants level originX originY tree relationships person =
    let
        -- _ =
        --     Debug.log ("----------" ++ person.firstName) ""
        hasAncestors =
            level /= 0
    in
    Svg.g []
        [ if hasAncestors then
            Svg.line
                -- vertical line on top of child
                [ SA.stroke Color.darkGrey
                , SA.strokeWidth <| Px 1
                , InPx.x1 (originX + personWidth / 2)
                , InPx.y1 (originY - (personHeight / 2))
                , InPx.x2 (originX + personWidth / 2)
                , InPx.y2 originY
                ]
                []

          else
            SC.text ""
        , viewPersonBox True originX originY person

        -- , viewPersonBox True (originX - personWidth / 2) originY person
        , person.relationship
            |> Maybe.map
                (\relId ->
                    let
                        maybeRelationship =
                            relationships
                                |> List.filter (.id >> (==) relId)
                                |> List.head
                    in
                    case maybeRelationship of
                        Nothing ->
                            SC.text ""

                        Just rel ->
                            case getSpouse tree person relId of
                                Nothing ->
                                    SC.text ""

                                Just spouse ->
                                    let
                                        children =
                                            rel.children |> List.filterMap (getPersonFromId tree)

                                        spouseX =
                                            originX + personWidth + widthBetweenSpouses

                                        centerX =
                                            originX + (parentsWidth / 2)

                                        absoluteFirstSiblingX1 =
                                            getChildrenBounds originX tree relationships person
                                                |> Dict.get 0
                                                |> Maybe.map .x1
                                                |> Maybe.withDefault 0

                                        -- |> Debug.log ("children origin for " ++ person.firstName)
                                        positionAndViewForEachChild : Float -> List ( Float, SC.Svg Msg )
                                        positionAndViewForEachChild finalOffset =
                                            rel.children
                                                |> List.indexedMap Tuple.pair
                                                |> Dict.fromList
                                                |> Dict.foldl
                                                    (\idx childId positionAndViewChildrenAcc ->
                                                        case getPersonFromId tree childId of
                                                            Nothing ->
                                                                positionAndViewChildrenAcc

                                                            Just child ->
                                                                let
                                                                    absolutePreviousSiblingPosition =
                                                                        getAbsolutePosition absoluteFirstSiblingX1 children (idx - 1)

                                                                    previousSiblingPosition =
                                                                        Dict.get (idx - 1) positionAndViewChildrenAcc
                                                                            |> Maybe.map Tuple.first
                                                                            |> Maybe.withDefault absolutePreviousSiblingPosition

                                                                    previousSiblingOffset =
                                                                        previousSiblingPosition - absolutePreviousSiblingPosition

                                                                    absolutePosition =
                                                                        getAbsolutePosition absoluteFirstSiblingX1 children idx
                                                                            + previousSiblingOffset

                                                                    -- |> Debug.log ("absolute position for" ++ child.firstName)
                                                                    childrenBounds =
                                                                        getChildrenBounds absolutePosition tree relationships child

                                                                    maxX2ByLevel =
                                                                        getPreviousSiblingsMaxX2ForEachLevel positionAndViewChildrenAcc absoluteFirstSiblingX1 tree relationships children idx

                                                                    offset =
                                                                        getOffset childrenBounds maxX2ByLevel

                                                                    -- |> Debug.log ("offset for " ++ child.firstName)
                                                                    x1 =
                                                                        absolutePosition
                                                                            + offset

                                                                    -- |> Debug.log ("X1 for " ++ child.firstName)
                                                                in
                                                                positionAndViewChildrenAcc
                                                                    |> Dict.insert idx
                                                                        ( x1
                                                                        , child |> viewPersonWithDescendants (level + 1) (x1 + finalOffset - personWidth / 2) (originY + heightBetweenParentsAndChildren) tree relationships
                                                                          -- , child |> viewPersonWithDescendants (level + 1) x1 (originY + heightBetweenParentsAndChildren) tree
                                                                        )
                                                    )
                                                    Dict.empty
                                                |> Dict.values

                                        minX =
                                            positionAndViewForEachChild 0
                                                |> List.map Tuple.first
                                                |> List.minimum
                                                |> Maybe.withDefault 0

                                        maxX =
                                            positionAndViewForEachChild 0
                                                |> List.map Tuple.first
                                                |> List.maximum
                                                |> Maybe.withDefault 0

                                        currentChildrenCenterX =
                                            minX
                                                + ((maxX - minX) / 2)

                                        -- |> Debug.log ("currentchildrencenterX for " ++ person.firstName)
                                        offsetToCenter =
                                            -(currentChildrenCenterX - centerX)
                                    in
                                    Svg.g []
                                        ([ Svg.line
                                            -- horiz line between spouses
                                            [ SA.stroke Color.darkGrey
                                            , SA.strokeWidth <| Px 1

                                            -- , InPx.x1 (originX + 150)
                                            , InPx.x1 (originX + 150)
                                            , InPx.y1 (originY + (personHeight / 2))
                                            , InPx.x2 spouseX
                                            , InPx.y2 (originY + (personHeight / 2))
                                            ]
                                            []
                                         , if rel.children == [] then
                                            SC.text ""

                                           else
                                            Svg.line
                                                -- vert line between spouses
                                                [ SA.stroke Color.darkGrey
                                                , SA.strokeWidth <| Px 1
                                                , InPx.x1 centerX
                                                , InPx.y1 (originY + (personHeight / 2))
                                                , InPx.x2 centerX
                                                , InPx.y2 (originY + 60)
                                                ]
                                                []
                                         , if rel.children == [] then
                                            SC.text ""

                                           else
                                            Svg.line
                                                -- horiz line on top of children
                                                [ SA.stroke Color.darkGrey
                                                , SA.strokeWidth <| Px 1
                                                , InPx.x1 (minX + offsetToCenter)
                                                , InPx.y1 (originY + (personHeight / 2) + (heightBetweenParentsAndChildren / 2))

                                                -- , InPx.x2 ((maxX + offsetToCenter) + (personWidth / 2))
                                                , InPx.x2 (maxX + offsetToCenter)
                                                , InPx.y2 (originY + (personHeight / 2) + (heightBetweenParentsAndChildren / 2))
                                                ]
                                                []
                                         , viewPersonBox False spouseX originY spouse
                                         ]
                                            ++ (positionAndViewForEachChild offsetToCenter |> List.map Tuple.second)
                                        )
                )
            |> Maybe.withDefault (SC.text "")
        ]


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


getPreviousSiblingsMaxX2ForEachLevel : Dict Int ( Float, SC.Svg Msg ) -> Float -> List Person -> List Relationship -> List Person -> Int -> Dict Int Float
getPreviousSiblingsMaxX2ForEachLevel positionAndViewChildrenAcc firstSiblingX1 tree relationships children currentIndex =
    let
        getPreviousSiblingBounds ix sib =
            Dict.get ix positionAndViewChildrenAcc
                |> Maybe.map Tuple.first
                |> Maybe.withDefault (getAbsolutePosition firstSiblingX1 children ix)
                |> (\pos -> getChildrenBounds pos tree relationships sib)
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


getPersonDescendants : Int -> List Person -> List Relationship -> Person -> Dict Int (List Person) -> Dict Int (List Person)
getPersonDescendants level tree relationships currentPerson currentDict =
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
                                                |> getPersonDescendants (level + 1) tree relationships child

                                        Nothing ->
                                            acc
                                )
                                currentDict
                    )
                |> Maybe.withDefault currentDict


type alias Bounds =
    { x1 : Float, x2 : Float }


getChildrenBounds : Float -> List Person -> List Relationship -> Person -> Dict Int Bounds
getChildrenBounds parentX1 tree relationships currentPerson =
    let
        descendants : Dict Int (List Person)
        descendants =
            getPersonDescendants 0 tree relationships currentPerson Dict.empty

        parentsCenter =
            parentX1 + (parentsWidth / 2)
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
                        (toFloat numberOfSiblings * personWidth)
                            + (toFloat (numberOfSiblings - 1) * widthBetweenSiblings)
                            + (toFloat numberOfSpouses * (personWidth + widthBetweenSpouses))
                in
                { x1 = parentsCenter - (width / 2), x2 = parentsCenter + (width / 2) }
            )


getChildAtIndex : List Person -> Int -> List Id -> Maybe Person
getChildAtIndex tree index childrenIds =
    childrenIds
        |> LE.getAt index
        |> Maybe.andThen (getPersonFromId tree)


hasSpouse : Person -> Bool
hasSpouse person =
    person.relationship /= Nothing


personWidth : Float
personWidth =
    150


personHeight : Float
personHeight =
    40


heightBetweenParentsAndChildren : Float
heightBetweenParentsAndChildren =
    80


widthBetweenSiblings : Float
widthBetweenSiblings =
    36


widthBetweenSpouses : Float
widthBetweenSpouses =
    24


parentsWidth : Float
parentsWidth =
    2 * personWidth + widthBetweenSpouses


viewPersonBox : Bool -> Float -> Float -> Person -> SC.Svg Msg
viewPersonBox fromFamily x y person =
    let
        color =
            if person.sex == Male then
                Color.lightBlue

            else
                Color.orange

        paddingLeft =
            10
    in
    Svg.g
        [ SE.onClick <| SelectedLastName person.lastName
        , SA.cursor CursorPointer
        ]
        [ Svg.rect
            [ InPx.x x
            , InPx.y y
            , InPx.width personWidth
            , InPx.height personHeight
            , SA.stroke color
            , SA.strokeWidth <| Px <| 1
            , SA.fill <|
                Fill <|
                    if fromFamily then
                        Color.white

                    else
                        Color.lightGrey
            ]
            []
        , Svg.text_
            [ InPx.x (x + paddingLeft)
            , InPx.y (y + 16)
            , SA.fill <|
                Fill
                    (if fromFamily then
                        Color.black

                     else
                        Color.charcoal
                    )
            , InPx.fontSize 12
            ]
            [ SC.text <| cropAndAddEllipsis 21 person.firstName ]
        , Svg.text_
            [ InPx.x (x + paddingLeft)
            , InPx.y (y + 31)
            , SA.fill <|
                Fill
                    (if fromFamily then
                        Color.black

                     else
                        Color.charcoal
                    )
            , InPx.fontSize 12
            ]
            [ SC.text <| String.toUpper <| cropAndAddEllipsis 21 person.lastName ]
        ]


cropAndAddEllipsis : Int -> String -> String
cropAndAddEllipsis maxLength str =
    if String.length str <= maxLength then
        str

    else
        String.left (maxLength - 3) str ++ "..."


getPersonName : Person -> String
getPersonName person =
    person.firstName ++ " " ++ String.toUpper person.lastName


getPersonFromId : List Person -> Id -> Maybe Person
getPersonFromId tree id =
    tree
        |> List.filter (.id >> (==) id)
        |> List.head


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
                                            maxX2 - bounds.x1 + widthBetweenSiblings

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
        + ((personWidth + widthBetweenSiblings) * toFloat idx)
        + ((personWidth + widthBetweenSpouses) * toFloat (getNumberOfPreviousSiblingsSpouses children idx))


getSpouse : List Person -> Person -> Id -> Maybe Person
getSpouse tree person relId =
    tree
        |> List.filter (\p -> p.relationship == Just relId && p.firstName /= person.firstName && p.lastName /= person.lastName)
        |> List.head
