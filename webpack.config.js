const path = require('path');
const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  entry: {
    app: [
      './src/app.js'
    ]
  },

  output: {
    path: path.resolve(__dirname + '/dist'),
    publicPath: '/',
    filename: '[name].js',
  },

  resolve: {
    extensions: ['.js', '.elm']
  },

  module: {
    loaders: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: 'elm-webpack-loader',
      },
      {
        test: /\.js$/,
        exclude: [/node_modules/],
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['env']
          }
        }
      }
    ],

    noParse: /\.elm$/,
  },

  plugins: [
    new HtmlWebpackPlugin({
      template: './src/index.html',
      hash: true
    })
  ],

  devServer: {
    inline: true,
    stats: { colors: true }
  },

};
