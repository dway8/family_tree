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
    }


type alias Person =
    { id : Id
    , firstName : String
    , lastName : String
    , sex : Sex
    , relationship : Maybe Relationship
    }


type alias Relationship =
    { spouse : Id
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
              , relationship = Just { spouse = 4, children = [ 5, 6 ] }
              }
            , { id = 2
              , firstName = "Blandine"
              , lastName = "Jantet"
              , sex = Female
              , relationship = Just { spouse = 3, children = [ 1, 9, 10, 18 ] }
              }
            , { id = 3
              , firstName = "Olivier"
              , lastName = "Manière"
              , sex = Male
              , relationship = Just { spouse = 2, children = [ 1, 9, 10, 18 ] }
              }
            , { id = 4
              , firstName = "Orlane"
              , lastName = "Félix"
              , sex = Female
              , relationship = Just { spouse = 1, children = [ 5, 6 ] }
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
              , relationship = Just { spouse = 8, children = [ 16, 17, 2 ] }
              }
            , { id = 8
              , firstName = "Georges"
              , lastName = "Jantet"
              , sex = Male
              , relationship = Just { spouse = 7, children = [ 16, 17, 2 ] }
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
              , relationship = Just { spouse = 19, children = [ 20, 21, 22 ] }
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
              , relationship = Just { spouse = 15, children = [ 11, 3, 13 ] }
              }
            , { id = 15
              , firstName = "Paul-Henry"
              , lastName = "Manière"
              , sex = Female
              , relationship = Just { spouse = 14, children = [ 11, 3, 13 ] }
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
              , relationship = Nothing
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
              , relationship = Just { spouse = 11, children = [ 20, 21, 22 ] }
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
viewTree { tree, lastName } =
    let
        allChildrenIds =
            tree |> List.filterMap .relationship |> List.concatMap .children

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
        el [ padding 20, width fill, height fill ] <|
            html <|
                Svg.svg
                    [ SA.width <| Px 1700
                    , SA.height <| Px 600
                    , SA.viewBox 0 0 1700 600
                    , SA.preserveAspectRatio (Align ScaleMin ScaleMin) Meet
                    ]
                    (case firstAncestor of
                        Nothing ->
                            []

                        Just ancestor ->
                            [ viewPersonWithDescendants 0 600 100 tree ancestor ]
                    )


viewPersonWithDescendants : Int -> Float -> Float -> List Person -> Person -> SC.Svg Msg
viewPersonWithDescendants level originX originY tree person =
    let
        hasAncestors =
            level /= 0
    in
    Svg.g []
        [ if hasAncestors then
            Svg.line
                -- vertical line on top of child
                [ SA.stroke Color.darkGrey
                , SA.strokeWidth <| Px 1
                , InPx.x1 (originX + (personWidth / 2))
                , InPx.y1 (originY - (personHeight / 2))
                , InPx.x2 (originX + (personWidth / 2))
                , InPx.y2 originY
                ]
                []

          else
            SC.text ""
        , viewPersonBox True originX originY person
        , person.relationship
            |> Maybe.map
                (\rel ->
                    case getPersonFromId tree rel.spouse of
                        Nothing ->
                            SC.text ""

                        Just spouse ->
                            let
                                children =
                                    rel.children |> List.filterMap (getPersonFromId tree)

                                spouseX =
                                    originX + personWidth + widthBetweenSpouses

                                numberOfChildren =
                                    List.length rel.children

                                centerX =
                                    originX + (parentsWidth / 2)

                                absoluteChildrenBoundsByLevel =
                                    getChildrenBounds originX tree person

                                directChildrenBounds =
                                    Dict.get 0 absoluteChildrenBoundsByLevel
                                        |> Maybe.withDefault (Bounds 0 0)

                                childrenOrigin =
                                    directChildrenBounds.x1

                                positionAndViewForEachChild : List ( Float, SC.Svg Msg )
                                positionAndViewForEachChild =
                                    rel.children
                                        |> List.indexedMap Tuple.pair
                                        |> Dict.fromList
                                        |> Dict.foldl
                                            (\idx childId acc ->
                                                case getPersonFromId tree childId of
                                                    Nothing ->
                                                        acc

                                                    Just child ->
                                                        let
                                                            absolutePreviousSiblingPosition =
                                                                childrenOrigin
                                                                    + ((personWidth + widthBetweenSiblings) * toFloat (idx - 1))
                                                                    + ((personWidth + widthBetweenSpouses) * toFloat (getNumberOfPreviousSiblingsSpouses children (idx - 1)))

                                                            previousSiblingPosition =
                                                                Dict.get (idx - 1) acc
                                                                    |> Maybe.map Tuple.first
                                                                    |> Maybe.withDefault absolutePreviousSiblingPosition

                                                            absolutePosition =
                                                                childrenOrigin
                                                                    + ((personWidth + widthBetweenSiblings) * toFloat idx)
                                                                    + ((personWidth + widthBetweenSpouses) * toFloat (getNumberOfPreviousSiblingsSpouses children idx))
                                                                    + (previousSiblingPosition - absolutePreviousSiblingPosition)

                                                            directChildChildrenBounds =
                                                                getChildrenBounds absolutePosition tree child

                                                            previousSiblingsMaxX2ForEachLevel =
                                                                getPreviousSiblingsMaxX2ForEachLevel childrenOrigin tree rel.children idx

                                                            overlapForEachLevel =
                                                                directChildChildrenBounds
                                                                    |> Dict.foldr
                                                                        (\l bounds overlapAcc ->
                                                                            let
                                                                                maybePreviousSiblingsLevelMaxX2 =
                                                                                    Dict.get l previousSiblingsMaxX2ForEachLevel
                                                                            in
                                                                            case maybePreviousSiblingsLevelMaxX2 of
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

                                                            maxOverlap =
                                                                overlapForEachLevel
                                                                    |> Dict.values
                                                                    |> List.maximum
                                                                    |> Maybe.withDefault 0

                                                            x1 =
                                                                absolutePosition + maxOverlap
                                                        in
                                                        acc
                                                            |> Dict.insert idx
                                                                ( x1
                                                                , child |> viewPersonWithDescendants (level + 1) x1 (originY + heightBetweenParentsAndChildren) tree
                                                                )
                                            )
                                            Dict.empty
                                        |> Dict.values
                            in
                            Svg.g []
                                ([ Svg.line
                                    -- horiz line between spouses
                                    [ SA.stroke Color.darkGrey
                                    , SA.strokeWidth <| Px 1
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
                                    let
                                        minX =
                                            positionAndViewForEachChild
                                                |> List.map Tuple.first
                                                |> List.minimum
                                                |> Maybe.withDefault 0

                                        maxX =
                                            positionAndViewForEachChild
                                                |> List.map Tuple.first
                                                |> List.maximum
                                                |> Maybe.withDefault 0
                                    in
                                    Svg.line
                                        -- horiz line on top of children
                                        [ SA.stroke Color.darkGrey
                                        , SA.strokeWidth <| Px 1
                                        , InPx.x1 (minX + (personWidth / 2))
                                        , InPx.y1 (originY + (personHeight / 2) + (heightBetweenParentsAndChildren / 2))
                                        , InPx.x2 (maxX + (personWidth / 2))
                                        , InPx.y2 (originY + (personHeight / 2) + (heightBetweenParentsAndChildren / 2))
                                        ]
                                        []
                                 , viewPersonBox False spouseX originY spouse
                                 ]
                                    ++ (positionAndViewForEachChild |> List.map Tuple.second)
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


getPreviousSiblingsMaxX2ForEachLevel : Float -> List Person -> List Id -> Int -> Dict Int Float
getPreviousSiblingsMaxX2ForEachLevel childrenOrigin tree childrenIds currentIndex =
    let
        indexesToLookUp =
            List.range 0 (currentIndex - 1)
    in
    indexesToLookUp
        |> List.foldl
            (\idx acc ->
                LE.getAt idx childrenIds
                    |> Maybe.andThen (getPersonFromId tree)
                    |> Maybe.map
                        (\child ->
                            let
                                currentChildrenBounds =
                                    getChildrenBounds childrenOrigin tree child
                            in
                            currentChildrenBounds
                                |> Dict.foldl
                                    (\k { x2 } acc2 ->
                                        acc2
                                            |> Dict.update k (\maybeVal -> max x2 (maybeVal |> Maybe.withDefault 0) |> Just)
                                    )
                                    acc
                        )
                    |> Maybe.withDefault acc
            )
            Dict.empty


getPersonDescendants : Int -> List Person -> Person -> Dict Int (List Person) -> Dict Int (List Person)
getPersonDescendants level tree currentPerson currentDict =
    let
        addChildToDescendantsAcc child acc =
            acc
                |> Dict.update level (\maybeVal -> child :: (maybeVal |> Maybe.withDefault []) |> Just)
    in
    currentPerson.relationship
        |> Maybe.map
            (\{ children } ->
                children
                    |> List.foldr
                        (\childId acc ->
                            case getPersonFromId tree childId of
                                Just child ->
                                    acc
                                        |> addChildToDescendantsAcc child
                                        |> getPersonDescendants (level + 1) tree child

                                Nothing ->
                                    acc
                        )
                        currentDict
            )
        |> Maybe.withDefault currentDict


type alias Bounds =
    { x1 : Float, x2 : Float }


getChildrenBounds : Float -> List Person -> Person -> Dict Int Bounds
getChildrenBounds parentX1 tree currentPerson =
    let
        descendants : Dict Int (List Person)
        descendants =
            getPersonDescendants 0 tree currentPerson Dict.empty

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
            [ InPx.x (x + 10)
            , InPx.y (y + 20)
            , SA.fill <|
                Fill
                    (if fromFamily then
                        Color.black

                     else
                        Color.charcoal
                    )
            , InPx.fontSize 12
            ]
            [ SC.text <| getPersonName person ]
        ]


getPersonName : Person -> String
getPersonName person =
    person.firstName ++ " " ++ String.toUpper person.lastName


getPersonFromId : List Person -> Id -> Maybe Person
getPersonFromId tree id =
    tree
        |> List.filter (.id >> (==) id)
        |> List.head
