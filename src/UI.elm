module UI exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input
import Html
import Html.Attributes as HA
import UI.Button as Button
import UI.Color
import ViewUtils


type alias TextInputConfig msg =
    { onChange : String -> msg
    , label : Maybe String
    , text : String
    , placeholder : Maybe (Element msg)
    }


textInput : List (Attribute msg) -> TextInputConfig msg -> Element msg
textInput attrs config =
    Input.text
        (Font.size 16 :: attrs)
        { onChange = config.onChange
        , label =
            config.label
                |> Maybe.map (\l -> Input.labelAbove [ Font.color UI.Color.darkerGrey ] <| text l)
                |> Maybe.withDefault (Input.labelHidden "")
        , text = config.text
        , placeholder = Maybe.map (Input.placeholder [ moveLeft 1, moveUp 1 ]) <| config.placeholder
        }


cropAndAddEllipsis : Int -> String -> String
cropAndAddEllipsis maxLength str =
    if String.length str <= maxLength then
        str

    else
        String.left (maxLength - 3) str ++ "..."


type alias DialogConfig msg =
    { header : Maybe (Element msg)
    , size : Attribute msg
    , body : Element msg
    , closable : Maybe msg
    , footer : Maybe (Element msg)
    }


viewDialog : DialogConfig msg -> Element msg
viewDialog config =
    let
        bodyBottomPadding =
            config.footer
                |> Maybe.map (always 0)
                |> Maybe.withDefault 20
    in
    el
        [ width fill
        , height fill
        , behindContent <|
            el
                ([ width fill
                 , height fill
                 , Background.color (UI.Color.makeOpaque 0.3 UI.Color.black)
                 ]
                    ++ (case config.closable of
                            Just msg ->
                                [ onClick msg ]

                            Nothing ->
                                []
                       )
                )
                none
        , inFront <|
            el
                [ htmlAttribute <| HA.style "height" "100%"
                , htmlAttribute <| HA.style "width" "100%"
                , htmlAttribute <| HA.style "pointer-events" "none"
                , htmlAttribute <| HA.style "position" "fixed"
                ]
            <|
                el
                    [ centerX
                    , centerY
                    , htmlAttribute <| HA.style "pointer-events" "all"
                    , htmlAttribute <| HA.style "max-height" "95%"
                    , Background.color UI.Color.white
                    , Border.rounded 5
                    , Border.glow (UI.Color.makeOpaque 0.2 UI.Color.black) 0.4
                    , config.size
                    , inFront <| dialogHeader config.header config.closable
                    ]
                <|
                    column [ scrollbarY, width fill, paddingEach { bottom = bodyBottomPadding, left = 20, top = 20, right = 20 }, spacing 40 ]
                        [ config.body
                        , config.footer |> Maybe.withDefault none
                        ]
        ]
    <|
        none


dialogHeader : Maybe (Element msg) -> Maybe msg -> Element msg
dialogHeader maybeHeader closeMsg =
    maybeHeader
        |> Maybe.map
            (\header ->
                row
                    [ Background.color UI.Color.white
                    , width fill
                    , spaceEvenly
                    , Border.roundEach { topLeft = 5, topRight = 5, bottomLeft = 0, bottomRight = 0 }
                    , Border.widthEach { bottom = 2, left = 0, right = 0, top = 0 }
                    , paddingEach { bottom = 12, left = 20, right = 20, top = 20 }
                    , Border.color UI.Color.lightestGrey
                    ]
                    [ header
                    , case closeMsg of
                        Just msg ->
                            el [ Font.size 25, Font.color UI.Color.darkGrey, onClick msg, pointer, htmlAttribute <| HA.id "close-dialog-btn" ] <| icon "close"

                        Nothing ->
                            none
                    ]
            )
        |> Maybe.withDefault none


icon : String -> Element msg
icon =
    html << htmlIcon


htmlIcon : String -> Html.Html msg
htmlIcon ico =
    Html.i [ HA.class ("zmdi zmdi-" ++ ico) ] []


largeModal : Attribute msg
largeModal =
    width <| maximum 700 fill


midModal : Attribute msg
midModal =
    width <| maximum 650 fill


smallModal : Attribute msg
smallModal =
    width <| maximum 510 fill


smallSpacing : Attribute msg
smallSpacing =
    spacing 5


defaultSpacing : Attribute msg
defaultSpacing =
    spacing 10


largeSpacing : Attribute msg
largeSpacing =
    spacing 20


defaultButton : Maybe msg -> Element msg -> Button.ButtonTemplate msg
defaultButton maybeMsg elem =
    Button.makeButton maybeMsg elem
        |> Button.withFontSize (Font.size 16)
        |> Button.withRounded (Border.rounded 4)


defaultDialogFooter : msg -> msg -> Bool -> Bool -> Element msg
defaultDialogFooter cancelMsg validateMsg disableByDefault isLoading =
    let
        isDisabled =
            disableByDefault || isLoading

        ( alphaValue, cursor ) =
            if isDisabled then
                ( 0.5, notAllowedCursor )

            else
                ( 1, pointer )
    in
    row [ spacing 10, alignRight, paddingEach { bottom = 20, left = 20, top = 0, right = 20 } ]
        [ Input.button [ htmlAttribute <| HA.disabled isDisabled, Background.color UI.Color.lightestGrey, paddingXY 25 10, Border.rounded 3 ]
            { label = text "Annuler"
            , onPress =
                if isLoading then
                    Nothing

                else
                    Just cancelMsg
            }
        , Input.button
            [ htmlAttribute <| HA.disabled <| isDisabled
            , Background.color UI.Color.green
            , paddingXY 25 10
            , Border.rounded 3
            , Font.color UI.Color.white
            , cursor
            , htmlAttribute <| HA.class "validate-btn"
            , alpha alphaValue
            ]
            { label =
                row [ spacing 5 ]
                    [ ViewUtils.viewIf isLoading <| el [] <| icon "spinner zmdi-hc-spin"
                    , text "Valider"
                    ]
            , onPress =
                if isDisabled then
                    Nothing

                else
                    Just validateMsg
            }
        ]


notAllowedCursor : Attribute msg
notAllowedCursor =
    htmlAttribute <| HA.style "cursor" "not-allowed"
