module Main exposing (..)

import Html exposing (Html)
import Core
import UI
import UI.Types as View
import RandomCodeGenerator


main : Program Never (Core.Model View.Model) (Core.Msg View.Msg)
main =
  Html.program
    { init = Core.initGame RandomCodeGenerator.generate UI.defaultModel
    , view = Core.view UI.view
    , update = Core.update UI.update
    , subscriptions = (\_ -> Sub.none)
    }
