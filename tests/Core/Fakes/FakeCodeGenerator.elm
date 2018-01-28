module Core.Fakes.FakeCodeGenerator exposing (..)

import Elmer.Platform.Command as Command
import Core.Types exposing (Color(..))

with : List Color -> Color -> List Color -> Int -> (List Color -> msg) -> Cmd msg
with code default colors num tagger =
  Command.fake <| tagger code
