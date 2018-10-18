module Game.Fakes.FakeCodeGenerator exposing (..)

import Elmer.Command as Command
import Game.Types exposing (Color, Code)

with : Code -> (Code -> msg) -> Cmd msg
with code tagger =
  Command.fake <| tagger code
