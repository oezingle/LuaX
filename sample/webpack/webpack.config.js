var path = require('path');

module.exports = {
    entry: {
        index: './src/index.js',
    },
    output: {
        path: path.resolve(__dirname, "public"),
        filename: '[name].bundle.js'
    },
    devServer: {
        port: 3000,
        hot: true,
        historyApiFallback: {
            index: '/'
        },
    },
    devtool: 'inline-source-map',
    mode: "development",
    resolve: {
        fallback: {
            path: false,
            fs: false,
            child_process: false,
            crypto: false,
            url: false,
            module: false,
        },
    },
    optimization: {
        usedExports: true,
        runtimeChunk: "single",
    },
};