// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css";

import "phoenix_html";

import { Elm } from "../src/Main.elm";

var node = document.getElementById("elm-main");

var now = new Date().getTime();
var app = Elm.Main.init({
    node,
    flags: { now },
});
