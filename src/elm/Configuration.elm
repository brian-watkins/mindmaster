module Configuration exposing
  ( program
  , coreAdapters
  )

import Html exposing (Html)
import Bus
import Game.Types exposing (GameConfig, Color(..))
import UI
import UI.Types as View
import CodeGenerator.RandomCodeGenerator as RandomCodeGenerator
import ScoreStore.LocalStorageScoreStore as LocalStorageScoreStore


codeLength = 5

topScores = 5

colors =
  [ Red
  , Orange
  , Yellow
  , Green
  , Blue
  ]


gameConfig =
  { maxGuesses = 10
  }


viewConfig =
  { codeLength = codeLength
  , colors = colors
  }


defaultViewModel =
  UI.defaultModel viewConfig


coreAdapters =
  { codeGenerator = RandomCodeGenerator.generator codeLength None colors
  , updateUI = UI.update
  , guessResultTagger = UI.guessResultTagger
  , updateScoreStore = LocalStorageScoreStore.execute
  }


subscriptions model =
  Sub.batch
  [ Bus.subscriptions model
  , LocalStorageScoreStore.subscriptions topScores (Bus.uiTagger << UI.highScoresTagger)
  ]


program adapters =
  Html.program
    { init = Bus.init gameConfig adapters defaultViewModel
    , view = Bus.view UI.view
    , update = Bus.update adapters
    , subscriptions = subscriptions
    }
