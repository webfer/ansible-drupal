// Imports

const path = require('path');
const webpack = require('webpack');
const globImporter = require('node-sass-glob-importer');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const svgToMiniDataURI = require('mini-svg-data-uri');

// Set variables by environment

let isProd = (process.env.NODE_ENV === 'production') ? true : false;

// Set plugins

let pluginsConfig = [];

if (isProd) {
  pluginsConfig = [
    new MiniCssExtractPlugin({filename: 'css/styles.css'})
  ];
}
else {
  pluginsConfig = [
    new MiniCssExtractPlugin({filename: 'css/styles.css'}),
    new webpack.SourceMapDevToolPlugin({})
  ]
}

// JS Optimization

if (isProd) {
  module.exports = {
    optimization: {
      minimize: true,
      minimizer: [new TerserPlugin()],
    },
  };
}

// Module configuration

module.exports = {
  devtool: isProd ? false : 'source-map',
  mode: isProd ? 'production' : 'development',
  stats: 'minimal',
  watch: isProd ? false : true,
  entry: path.resolve(__dirname, './src/js/index.js'),
  output: {
    filename: 'js/scripts.js',
    path: path.resolve(__dirname, 'assets'),
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /(node_modules|bower_components)/,
        enforce: "pre",
        use: [
          'source-map-loader',
          {
          loader: 'babel-loader',
            options: {
              presets: ['@babel/preset-env']
            }
          }
        ]
      },
      {
        test: /\.css$/,
        use: [
          {
            loader: MiniCssExtractPlugin.loader,
          },
          {
            loader: 'css-loader',
            options: {
              sourceMap: true,
            }
          }
        ],
      },
      {
        test: /\.scss$/,
        use: [
          MiniCssExtractPlugin.loader,
          {
            loader: 'css-loader',
            options: {
              sourceMap: true,
            }
          },
          {
            loader: "sass-loader",
            options: {
              sourceMap: true,
              sassOptions: {
                // @see: https://tinyurl.com/yzf754ed
                // importer: globImporter()
              }
            }
          },
          {
            loader: 'import-glob-loader'
          }
        ]
      },
      {
        test: /\.(png|jpg|jpeg|gif)$/,
        type: 'asset/resource',
        generator: {
          filename: 'img/[name][ext]'
        }
        // loader: 'file-loader',
        // options: {
        //   name: '[name].[ext]',
        //   outputPath: 'img',
        //   publicPath: '../img/',
        // }
      },
      // {
      //   test: /montserrat.*\.(eot|ttf|woff|woff2)$/,
      //   loader: 'file-loader',
      //   options: {
      //     name: '[name].[ext]',
      //     outputPath: 'fonts/montserrat',
      //     publicPath: '../fonts/montserrat/',
      //   }
      // },
      {
        test: /inter-tight.*\.(eot|ttf|woff|woff2)$/,
        type: 'asset/resource',
        generator: {
          filename: 'fonts/inter-tight/[name][ext]'
        }
        // loader: 'file-loader',
        // options: {
        //   name: '[name].[ext]',
        //   outputPath: 'fonts/inter-tight',
        //   publicPath: '../fonts/inter-tight/',
        // }
      },
      {
        test: /\.svg$/,
        type: 'asset/resource',
          generator: {
            filename: 'icons/[name][ext]'
          //   dataUrl: content => {
          //     content = content.toString();
          //     return svgToMiniDataURI(content);
          //  }
         }
        // loader: 'file-loader',
        // generator: {
        //   filename: 'icons/[name].[ext]'
        // }
        // options: {
        //   name: '[name].[ext]',
        //   outputPath: 'icons',
        //   publicPath: '../icons/',
        // }
      },
      {
        test: /bootstrap-icons\.(woff|woff2)$/,
        include: path.resolve(__dirname, './node_modules/bootstrap-icons/font/fonts'),
        type: 'asset/resource',
        generator: {
          filename: 'webfonts/[name][ext]'
        }
        // loader: 'file-loader',
        // options: {
        //   name: '[name].[ext]',
        //   outputPath: 'webfonts',
        //   publicPath: '../webfonts/',
        // }
      }
    ],
  },
  plugins: pluginsConfig
}
