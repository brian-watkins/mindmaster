module Configuration exposing
  ( program
  , coreAdapters
  )

import Html exposing (Html)
import Core
import Core.Types exposing (GameConfig, Color(..), CoreAdapters)
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


defaultViewModel : View.Model
defaultViewModel =
  UI.defaultModel viewConfig


coreAdapters : CoreAdapters View.Msg View.Model (Core.Msg View.Msg)
coreAdapters =
  { codeGenerator = RandomCodeGenerator.generator codeLength None colors
  , viewUpdate = UI.update
  , highScoresTagger = UI.highScoresTagger
  , updateScoreStore = LocalStorageScoreStore.execute
  }


subscriptions : (Core.Model View.Model) -> Sub (Core.Msg View.Msg)
subscriptions model =
  Sub.batch
  [ Core.subscriptions model
  , LocalStorageScoreStore.subscriptions (Core.highScoresTagger topScores UI.highScoresTagger)
  ]


program adapters =
  Html.program
    { init = Core.initGame gameConfig defaultViewModel
    , view = Core.view UI.view
    , update = Core.update adapters
    , subscriptions = subscriptions
    }
