module Main exposing (..)

import Html exposing (Html)
import Core
import View
import RandomCodeGenerator

-- type AppMsg
--   = AppMsg
--
-- type alias AppModel =
--   { name: String
--   }
--
-- defaultModel : AppModel
-- defaultModel =
--   { name = "Brian"
--   }

-- view : AppModel -> Html AppMsg
-- view model =
--   Html.h1 [] [ Html.text "YO!!" ]
--
-- update : AppMsg -> AppModel -> (AppModel, Cmd AppMsg)
-- update msg model =
--   ( model, Cmd.none )
--
-- init : (AppModel, Cmd AppMsg)
-- init =
--   ( defaultModel, Cmd.none )

-- subscriptions : model -> Sub AppMsg
-- subscriptions model =
--   Sub.none

main : Program Never (Core.Model View.Model) (Core.Msg View.Msg)
main =
  Html.program
    { init = Core.initGame RandomCodeGenerator.generate View.defaultModel
    , view = Core.view View.view
    , update = Core.update View.update
    , subscriptions = (\_ -> Sub.none)
    }
