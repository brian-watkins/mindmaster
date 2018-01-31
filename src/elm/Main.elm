module Main exposing (..)

import Html exposing (Html)
import Core
import Core.Types exposing (GameConfig)
import UI
import UI.Types as View
import RandomCodeGenerator


gameConfig : GameConfig (Core.Msg View.Msg)
gameConfig =
  { codeGenerator = RandomCodeGenerator.generate
  , maxGuesses = 10
  }

main : Program Never (Core.Model View.Model) (Core.Msg View.Msg)
main =
  Html.program
    { init = Core.initGame gameConfig UI.defaultModel
    , view = Core.view UI.view
    , update = Core.update UI.update
    , subscriptions = (\_ -> Sub.none)
    }
