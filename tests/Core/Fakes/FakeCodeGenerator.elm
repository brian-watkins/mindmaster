module Core.Fakes.FakeCodeGenerator exposing (..)

import Elmer.Platform.Command as Command
import Core.Types exposing (Color(..), Code)

with : Code -> Color -> List Color -> Int -> (Code -> msg) -> Cmd msg
with code default colors num tagger =
  Command.fake <| tagger code
