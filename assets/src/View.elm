module View exposing (..)

import Browser exposing (Document)
import Color
import Dict exposing (Dict)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Helpers
import Model exposing (..)
import Set
import TypedSvg as Svg exposing (svg)
import TypedSvg.Attributes as SA
import TypedSvg.Attributes.InPx as InPx
import TypedSvg.Core as SC
import TypedSvg.Events as SE
import TypedSvg.Types exposing (Align(..), CoordinateSystem(..), Cursor(..), Fill(..), Length(..), MeetOrSlice(..), Scale(..))
import UI
import UI.Button as Button
import UI.Color


view : Model -> Document Msg
view model =
    { title = "My app"
    , body =
        [ layout
            ([ Font.family
                [ Font.external
                    { name = "Roboto"
                    , url = "https://fonts.googleapis.com/css?family=Roboto:300,300italic,400,400italic,700"
                    }
                ]
             , height fill
             , width fill
             , Background.color (rgb255 250 250 250)
             ]
                ++ (case model.personDialog of
                        Nothing ->
                            []

                        Just personDialogConfig ->
                            [ inFront <| UI.viewDialog <| viewPersonDialog model.tree personDialogConfig ]
                   )
            )
          <|
            column [ width fill, height fill ]
                [ viewQuery model
                , viewTree model
                ]
        ]
    }


viewQuery : Model -> Element Msg
viewQuery model =
    el
        (case model.query of
            Nothing ->
                []

            Just query ->
                let
                    matchingLastNames =
                        model.tree
                            |> List.map .lastName
                            |> Set.fromList
                            |> Set.toList
                            |> List.filter (\n -> String.contains (String.toLower query) (String.toLower n))
                in
                [ below <|
                    column [ Background.color UI.Color.white, padding 10 ]
                        (matchingLastNames |> List.map (\n -> el [ pointer, onClick <| LastNameSelected n ] <| text n))
                ]
        )
    <|
        UI.textInput []
            { onChange = SearchQueryUpdated
            , label = Nothing
            , text = model.query |> Maybe.withDefault ""
            , placeholder = Just <| text "Rechercher un nom..."
            }


viewTree : Model -> Element Msg
viewTree ({ tree, relationships } as model) =
    case model.lastName of
        Nothing ->
            none

        Just lastName ->
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
                , InPx.x1 (originX + Model.personWidth / 2)
                , InPx.y1 (originY - (Model.personHeight / 2))
                , InPx.x2 (originX + Model.personWidth / 2)
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
                            case Helpers.getSpouse tree person relId of
                                Nothing ->
                                    SC.text ""

                                Just spouse ->
                                    let
                                        children =
                                            rel.children |> List.filterMap (Helpers.getPersonFromId tree)

                                        spouseX =
                                            originX + personWidth + widthBetweenSpouses

                                        centerX =
                                            originX + (parentsWidth / 2)

                                        absoluteFirstSiblingX1 =
                                            Helpers.getChildrenBounds originX tree relationships person
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
                                                        case Helpers.getPersonFromId tree childId of
                                                            Nothing ->
                                                                positionAndViewChildrenAcc

                                                            Just child ->
                                                                let
                                                                    absolutePreviousSiblingPosition =
                                                                        Helpers.getAbsolutePosition absoluteFirstSiblingX1 children (idx - 1)

                                                                    previousSiblingPosition =
                                                                        Dict.get (idx - 1) positionAndViewChildrenAcc
                                                                            |> Maybe.map Tuple.first
                                                                            |> Maybe.withDefault absolutePreviousSiblingPosition

                                                                    previousSiblingOffset =
                                                                        previousSiblingPosition - absolutePreviousSiblingPosition

                                                                    absolutePosition =
                                                                        Helpers.getAbsolutePosition absoluteFirstSiblingX1 children idx
                                                                            + previousSiblingOffset

                                                                    -- |> Debug.log ("absolute position for" ++ child.firstName)
                                                                    childrenBounds =
                                                                        Helpers.getChildrenBounds absolutePosition tree relationships child

                                                                    maxX2ByLevel =
                                                                        Helpers.getPreviousSiblingsMaxX2ForEachLevel positionAndViewChildrenAcc absoluteFirstSiblingX1 tree relationships children idx

                                                                    offset =
                                                                        Helpers.getOffset childrenBounds maxX2ByLevel

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
        [ SE.onClick <| PersonSelected person
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
            [ SC.text <| UI.cropAndAddEllipsis 21 person.firstName ]
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
            [ SC.text <| String.toUpper <| UI.cropAndAddEllipsis 21 person.lastName ]
        ]


viewPersonDialog : List Person -> PersonDialogConfig -> UI.DialogConfig Msg
viewPersonDialog tree config =
    { header = Nothing
    , size = UI.midModal
    , body = personDialogBody tree config
    , closable = Just PersonDialogClosed
    , footer = config.addingSpouseLastName |> Maybe.map (always <| personDialogFooter config)
    }


personDialogBody : List Person -> PersonDialogConfig -> Element Msg
personDialogBody tree { person, addingSpouseLastName, addingSpouseFirstName } =
    column [ width fill, Font.size 16, UI.defaultSpacing ]
        [ el [ Font.bold, Font.size 20 ] <| text <| Helpers.getPersonName person
        , person.relationship
            |> Maybe.map
                (\relId ->
                    row [ UI.smallSpacing ]
                        [ el [ Font.bold ] <|
                            text <|
                                case person.sex of
                                    Male ->
                                        "Épouse"

                                    Female ->
                                        "Époux"
                        , case Helpers.getSpouse tree person relId of
                            Nothing ->
                                text "Erreur"

                            Just spouse ->
                                text <| Helpers.getPersonName spouse
                        ]
                )
            |> Maybe.withDefault none
        , case ( addingSpouseLastName, addingSpouseFirstName ) of
            ( Just lastName, Just firstName ) ->
                row [ UI.defaultSpacing ]
                    [ el [] <|
                        UI.textInput []
                            { onChange = NewSpouseNameUpdated LastName
                            , label =
                                Just <|
                                    "Nom de famille de "
                                        ++ (if person.sex == Male then
                                                "l'épouse"

                                            else
                                                "l'époux"
                                           )
                            , text = lastName
                            , placeholder = Nothing
                            }
                    , el [] <|
                        UI.textInput []
                            { onChange = NewSpouseNameUpdated FirstName
                            , label =
                                Just <|
                                    "Prénom de "
                                        ++ (if person.sex == Male then
                                                "l'épouse"

                                            else
                                                "l'époux"
                                           )
                            , text = firstName
                            , placeholder = Nothing
                            }
                    ]

            _ ->
                person.relationship
                    |> Maybe.map (always none)
                    |> Maybe.withDefault
                        ((text <|
                            "Ajouter "
                                ++ (if person.sex == Male then
                                        "une épouse"

                                    else
                                        "un époux"
                                   )
                         )
                            |> UI.defaultButton (Just AddSpouseButtonPressed)
                            |> Button.withBackgroundColor UI.Color.green
                            |> Button.viewButton
                        )
        ]


personDialogFooter : PersonDialogConfig -> Element Msg
personDialogFooter config =
    UI.defaultDialogFooter PersonDialogClosed ConfirmRelationshipButtonPressed False False