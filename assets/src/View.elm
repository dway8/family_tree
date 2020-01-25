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
import RemoteData as RD exposing (RemoteData(..))
import Set
import Time
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
                ++ (case ( model.family, model.personDialog ) of
                        ( Success family, Just personDialogConfig ) ->
                            [ inFront <| UI.viewDialog <| viewPersonDialog family personDialogConfig ]

                        _ ->
                            []
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
                        model.family
                            |> RD.map .tree
                            |> RD.withDefault []
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
viewTree model =
    case ( model.family, model.lastName ) of
        ( Success ({ tree, relationships } as family), Just lastName ) ->
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
                                [ viewPersonWithDescendants 0 600 100 family ancestor ]
                        )

        _ ->
            none


viewPersonWithDescendants : Int -> Float -> Float -> Family -> Person -> SC.Svg Msg
viewPersonWithDescendants level originX originY ({ tree, relationships } as family) person =
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
                            case Helpers.getSpouse tree person rel of
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
                                            Helpers.getChildrenBounds originX family person
                                                |> Dict.get 0
                                                |> Maybe.map .x1
                                                |> Maybe.withDefault 0

                                        -- |> Debug.log ("children origin for " ++ person.firstName)
                                        positionAndViewForEachChild : Float -> List ( Float, SC.Svg Msg )
                                        positionAndViewForEachChild finalOffset =
                                            children
                                                |> List.sortBy (\p -> p.birthDate.year |> Maybe.withDefault 0)
                                                |> List.indexedMap Tuple.pair
                                                |> Dict.fromList
                                                |> Dict.foldl
                                                    (\idx child positionAndViewChildrenAcc ->
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
                                                                Helpers.getChildrenBounds absolutePosition family child

                                                            maxX2ByLevel =
                                                                Helpers.getPreviousSiblingsMaxX2ForEachLevel positionAndViewChildrenAcc absoluteFirstSiblingX1 family children idx

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
                                                                , child |> viewPersonWithDescendants (level + 1) (x1 + finalOffset - personWidth / 2) (originY + heightBetweenParentsAndChildren) family
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


viewPersonDialog : Family -> PersonDialogConfig -> UI.DialogConfig Msg
viewPersonDialog family config =
    { header = Nothing
    , size = UI.midModal
    , body = personDialogBody family config
    , closable = Just PersonDialogClosed
    , footer =
        case config.addingSpouse of
            Just _ ->
                Just <| personDialogFooter config ConfirmRelationshipButtonPressed

            Nothing ->
                case config.addingChild of
                    Just _ ->
                        Just <| personDialogFooter config ConfirmChildButtonPressed

                    Nothing ->
                        Nothing
    }


personDialogBody : Family -> PersonDialogConfig -> Element Msg
personDialogBody { tree, relationships } { person, addingSpouse, addingChild } =
    column [ width fill, Font.size 16, UI.defaultSpacing ]
        [ el [ Font.bold, Font.size 20 ] <| text <| Helpers.getPersonName person
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
                            none

                        Just rel ->
                            column [ UI.largeSpacing ]
                                [ row [ UI.smallSpacing ]
                                    [ el [ Font.bold ] <|
                                        text <|
                                            case person.sex of
                                                Male ->
                                                    "Épouse"

                                                Female ->
                                                    "Époux"
                                    , case Helpers.getSpouse tree person rel of
                                        Nothing ->
                                            text "Erreur"

                                        Just spouse ->
                                            text <| Helpers.getPersonName spouse
                                    ]
                                , column [ UI.defaultSpacing ]
                                    [ el [ Font.bold ] <| text "Enfants"
                                    , column []
                                        (rel.children
                                            |> List.map
                                                (\childId ->
                                                    Helpers.getPersonFromId tree childId
                                                        |> Maybe.map (\child -> text <| Helpers.getPersonName child)
                                                        |> Maybe.withDefault none
                                                )
                                        )
                                    , case addingChild of
                                        Just { firstName, sex } ->
                                            row [ UI.defaultSpacing ]
                                                [ el [] <|
                                                    UI.textInput []
                                                        { onChange = NewChildFirstNameUpdated
                                                        , label = Just <| "Prénom de l'enfant"
                                                        , text = firstName
                                                        , placeholder = Nothing
                                                        }
                                                , UI.radioInput []
                                                    { onChange = SelectedChildSex
                                                    , label = Nothing
                                                    , selected = sex |> Model.sexToString |> Just
                                                    , options = [ ( Model.sexToString Male, "Garçon" ), ( Model.sexToString Female, "Fille" ) ]
                                                    }
                                                ]

                                        _ ->
                                            "Ajouter un enfant"
                                                |> text
                                                |> UI.defaultButton (Just AddChildButtonPressed)
                                                |> Button.withBackgroundColor UI.Color.green
                                                |> Button.viewButton
                                    ]
                                ]
                )
            |> Maybe.withDefault
                (case addingSpouse of
                    Just { lastName, firstName } ->
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
                        (text <|
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


personDialogFooter : PersonDialogConfig -> Msg -> Element Msg
personDialogFooter config confirmMsg =
    UI.defaultDialogFooter PersonDialogClosed confirmMsg False False
