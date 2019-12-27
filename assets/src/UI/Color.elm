module UI.Color exposing (..)

import Element exposing (..)


white : Color
white =
    rgb255 255 255 255


lightestGrey : Color
lightestGrey =
    rgb255 244 244 244


grey : Color
grey =
    rgb255 178 178 178


darkGrey : Color
darkGrey =
    rgb255 136 136 136


darkerGrey : Color
darkerGrey =
    rgb255 101 101 101


black : Color
black =
    rgb255 0 0 0


green : Color
green =
    rgb255 39 203 139


makeOpaque : Float -> Color -> Color
makeOpaque opacity color =
    let
        rgb =
            toRgb color
    in
    rgba rgb.red rgb.green rgb.blue opacity


makeDarker : Float -> Color -> Color
makeDarker r color =
    let
        ratio =
            1 - r

        rgb =
            toRgb color

        darkerRed =
            rgb.red * ratio

        darkerGreen =
            rgb.green * ratio

        darkerBlue =
            rgb.blue * ratio
    in
    rgba darkerRed darkerGreen darkerBlue rgb.alpha


makeLighter : Float -> Color -> Color
makeLighter r color =
    let
        ratio =
            1 + r

        rgb =
            toRgb color

        lighterRed =
            rgb.red * ratio

        lighterGreen =
            rgb.green * ratio

        lighterBlue =
            rgb.blue * ratio
    in
    rgba lighterRed lighterGreen lighterBlue rgb.alpha
