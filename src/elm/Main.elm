module Main exposing (..)

import Html exposing (Html)
import Core
import Core.Types exposing (GameConfig, Color(..), CoreAdapters)
import UI
import UI.Types as View
import RandomCodeGenerator


codeLength = 5


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
  }


main : Program Never (Core.Model View.Model) (Core.Msg View.Msg)
main =
  Html.program
    { init = Core.initGame gameConfig defaultViewModel
    , view = Core.view UI.view
    , update = Core.update coreAdapters
    , subscriptions = (\_ -> Sub.none)
    }
