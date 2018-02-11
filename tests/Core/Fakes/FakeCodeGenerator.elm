module Core.Fakes.FakeCodeGenerator exposing (..)

import Elmer.Platform.Command as Command
import Core.Types exposing (Color, Code)

with : Code -> (Code -> msg) -> Cmd msg
with code tagger =
  Command.fake <| tagger code
