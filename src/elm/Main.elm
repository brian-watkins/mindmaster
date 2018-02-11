module Main exposing (..)

import Html exposing (Html)
import Core
import Core.Types exposing (GameConfig)
import UI
import UI.Types as View
import RandomCodeGenerator


codeLength = 5

gameConfig =
  { codeGenerator = RandomCodeGenerator.generator codeLength
  , maxGuesses = 10
  }

viewConfig =
  { codeLength = codeLength
  }

defaultUIModel : View.Model
defaultUIModel =
  UI.defaultModel viewConfig


main : Program Never (Core.Model View.Model) (Core.Msg View.Msg)
main =
  Html.program
    { init = Core.initGame gameConfig defaultUIModel
    , view = Core.view UI.view
    , update = Core.update UI.update
    , subscriptions = (\_ -> Sub.none)
    }
