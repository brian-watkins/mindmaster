module IntegrationTestMain exposing (..)

import Configuration
import CodeGenerator.StaticCodeGenerator as StaticCodeGenerator
import Game.Types exposing (Color(..))
import UI.Types as View


main =
  let
    coreAdapters = Configuration.coreAdapters
  in
    { coreAdapters
    | codeGenerator = StaticCodeGenerator.generator <| List.repeat 5 Yellow
    }
      |> Configuration.program
