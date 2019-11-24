module Configuration exposing
  ( program
  , coreAdapters
  )

import Html exposing (Html)
import Game.Types exposing (defaultColor, Color(..))
import UI
import UI.Types as UI
import UI.Action
import UI.View
import CodeGenerator.RandomCodeGenerator as RandomCodeGenerator
import ScoreStore.LocalStorageScoreStore as LocalStorageScoreStore
import Configuration.Program as ConfigurableProgram
import Configuration.Bus as Bus
import Random


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
  { codeGenerator = RandomCodeGenerator.generator Random.generate config.codeLength defaultColor colors
  , updateUI = UI.Action.update
  , guessResultTagger = UI.guessResultTagger
  , updateScoreStore = LocalStorageScoreStore.execute config.topScores
  , displayScores = UI.highScoresTagger
  }


init adapters config =
  Bus.init
    (gameConfig config)
    (adapters config)
    (UI.defaultModel <| viewConfig config)


subscriptions : Config -> Bus.Model UI.Model UI.Msg -> Sub (Bus.Msg UI.Msg)
subscriptions _ model =
  Bus.subscriptions model


program adapters =
  ConfigurableProgram.with
    { init = init adapters
    , view = \_ -> Bus.view UI.View.with
    , update = \config -> Bus.update (adapters config)
    , subscriptions = subscriptions
    }
