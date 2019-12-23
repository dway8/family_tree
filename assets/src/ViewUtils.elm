module ViewUtils exposing (..)

import Element exposing (..)


viewIf : Bool -> Element msg -> Element msg
viewIf b view =
    if b then
        view

    else
        none
