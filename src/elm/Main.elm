module Main exposing (..)

import Html exposing (Html)
import Core
import UI
import RandomCodeGenerator


main : Program Never (Core.Model UI.Model) (Core.Msg UI.Msg)
main =
  Html.program
    { init = Core.initGame RandomCodeGenerator.generate UI.defaultModel
    , view = Core.view UI.view
    , update = Core.update UI.update
    , subscriptions = (\_ -> Sub.none)
    }
