module UI exposing (TextInputConfig, textInput)

import Element exposing (..)
import Element.Font as Font
import Element.Input as Input
import UI.Color


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
