const path = require("path");
const glob = require("glob");
let merge = require("webpack-merge");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const UglifyJsPlugin = require("uglifyjs-webpack-plugin");
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");

let prod = "production";
let dev = "development";

// determine build env
let TARGET_ENV = process.env.npm_lifecycle_event === "build" ? prod : dev;
let isDev = TARGET_ENV === dev;
let isProd = TARGET_ENV === prod;

console.log(`WEBPACK GO! Building for ${TARGET_ENV}`);

let outputPath = path.resolve(__dirname + "/dist");
let outputFilename = "app.js";

let commonConfig = {
    output: {
        path: outputPath,
        filename: outputFilename,
    },
    performance: {
        hints: false,
    },

    optimization: {
        minimizer: [
            new UglifyJsPlugin({
                cache: true,
                parallel: true,
                sourceMap: false,
            }),
            new OptimizeCSSAssetsPlugin({}),
        ],
    },
    plugins: [
        new MiniCssExtractPlugin({
            filename: "../css/app.css",
        }),
    ],

    module: {
        rules: [
            {
                test: /\.css$/i,
                use: [
                    {
                        loader: MiniCssExtractPlugin.loader,
                        options: {
                            hmr: isDev,
                        },
                    },
                    "css-loader",
                ],
            },
        ],
    },
};

const devConfig = {
    devtool: "source-map",
    entry: path.join(__dirname, "./static/index.js"),
    devServer: {
        contentBase: [".", "./static", "./assets"],
        headers: {
            "Access-Control-Allow-Origin": "*",
        },
        stats: {
            assets: false,
            cached: false,
            cachedAssets: false,
            children: false,
            chunks: false,
            colors: true,
            depth: true,
            entrypoints: true,
            errorDetails: true,
            hash: false,
            modules: true,
            source: true,
            timings: true,
            version: false,
            warnings: true,
        },

        host: "0.0.0.0",

        hot: true,

        inline: true,
    },
    plugins: [
        new MiniCssExtractPlugin({ filename: "../css/app.css" }),
        new CopyWebpackPlugin([{ from: "static/", to: "../" }]),

        function() {
            if (typeof this.options.devServer.hot === "undefined") {
                this.plugin("done", function(stats) {
                    if (
                        stats.compilation.errors &&
                        stats.compilation.errors.length
                    ) {
                        console.log(stats.compilation.errors);
                        process.exit(1);
                    }
                });
            }
        },
    ],
    module: {
        rules: [
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                use: [
                    {
                        loader: "elm-hot-webpack-loader",
                    },
                    {
                        loader: "elm-webpack-loader",
                        options: {
                            verbose: true,
                            // warn: true,
                            debug: true,
                        },
                    },
                ],
            },
        ],
    },
};

if (isDev === true) {
    console.log("Serving locally...");
    console.log("-------", commonConfig.entry);
    module.exports = function() {
        return merge(commonConfig, devConfig);
    };
}

const prodConfig = {
    module: {
        rules: [
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                use: [
                    {
                        loader: "elm-webpack-loader",
                        options: {
                            optimize: true,
                        },
                    },
                ],
            },
        ],
    },
    plugins: [
        new CopyWebpackPlugin([{ from: "static/images/", to: "../images/" }]),
    ],
};

// additional webpack settings for prod env (when invoked via 'npm run build')
if (isProd === true) {
    console.log("Building for prod...");

    module.exports = function() {
        return merge(commonConfig, prodConfig);
    };
}
