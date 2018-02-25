module Configuration exposing
  ( program
  , coreAdapters
  )

import Html
import Bus
import Game.Types exposing (defaultColor, Color(..))
import UI
import UI.Action
import UI.View
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
  { codeGenerator = RandomCodeGenerator.generator codeLength defaultColor colors
  , updateUI = UI.Action.update
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
    , view = Bus.view UI.View.for
    , update = Bus.update adapters
    , subscriptions = subscriptions
    }
