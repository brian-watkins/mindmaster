module Configuration exposing
  ( program
  , coreAdapters
  )

import Html exposing (Html)
import Bus
import Game.Types exposing (defaultColor, Color(..))
import UI
import UI.Types as UI
import UI.Action
import UI.View
import CodeGenerator.RandomCodeGenerator as RandomCodeGenerator
import ScoreStore.LocalStorageScoreStore as LocalStorageScoreStore
import Configuration.Program as ConfigurableProgram


colors =
  [ Red
  , Orange
  , Yellow
  , Green
  , Blue
  ]


type alias Config =
  { maxGuesses : Int
  , topScores : Int
  , codeLength : Int
  }


viewConfig config =
  { codeLength = config.codeLength
  , colors = colors
  }


gameConfig config =
  { maxGuesses = config.maxGuesses
  }


coreAdapters config =
  { codeGenerator = RandomCodeGenerator.generator config.codeLength defaultColor colors
  , updateUI = UI.Action.update
  , guessResultTagger = UI.guessResultTagger
  , updateScoreStore = LocalStorageScoreStore.execute
  }


init adapters config =
  Bus.init
    (gameConfig config)
    (adapters config)
    (UI.defaultModel <| viewConfig config)


subscriptions : Config -> Bus.Model UI.Model -> Sub (Bus.Msg UI.Msg)
subscriptions config model =
  Sub.batch
  [ Bus.subscriptions model
  , LocalStorageScoreStore.subscriptions config.topScores (Bus.uiTagger << UI.highScoresTagger)
  ]


program adapters =
  ConfigurableProgram.with
    { init = init adapters
    , view = \_ -> Bus.view UI.View.with
    , update = \config -> Bus.update (adapters config)
    , subscriptions = subscriptions
    }
