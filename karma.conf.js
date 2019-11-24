// Karma configuration
// Generated on Sat Nov 23 2019 20:04:46 GMT-0500 (Eastern Standard Time)

module.exports = function(config) {
  config.set({

    // base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: '',

    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: [ "elm-spec" ],

    elmSpec: {
      specRoot: './specs',
      specs: './src/**/*Spec.elm',
      pathToElm: 'elm'
    },

    client: {
      elmSpec: {
        tags: [],
        endOnFailure: true
      }
    },

    // list of files / patterns to load in the browser
    files: [
      { pattern: 'src/elm/*.elm', included: false, served: false },
      { pattern: 'specs/src/**/*.elm', included: false, served: false },
      "src/style/style.scss"
    ],


    // list of files / patterns to exclude
    exclude: [],


    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors: {
      "**/*.elm": [ "elm-spec" ],
      "src/style/style.scss": [ "scss" ]
    },

    
    // test results reporter to use
    // possible values: 'dots', 'progress'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['elm-spec'],


    // web server port
    port: 9876,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,


    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['MyChrome'],

    customLaunchers: {
      MyChrome: {
        base: 'Chrome',
        flags: [
          '--disable-backgrounding-occluded-windows', // necessary to run tests when browser is not visible
        ]
      },
      MyChromeHeadless: {
        base: 'ChromeHeadless',
        flags: ['--no-sandbox']
      }
    },


    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    singleRun: false,

    // Concurrency level
    // how many browser should be started simultaneous
    concurrency: Infinity
  })
}
