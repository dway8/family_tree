"use strict";
var { Elm } = require("../src/Main.elm");

var node = document.getElementById("content");

var now = new Date().getTime();
var app = Elm.Main.init({
    node,
    flags: { now },
});
