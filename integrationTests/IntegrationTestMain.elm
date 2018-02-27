module IntegrationTestMain exposing (..)

import Configuration
import CodeGenerator.StaticCodeGenerator as StaticCodeGenerator
import Game.Types exposing (Color(..))
import UI.Types as View


main =
  Configuration.program <|
    \flags ->
      let
        coreAdapters = Configuration.coreAdapters flags
      in
        { coreAdapters
        | codeGenerator = StaticCodeGenerator.generator <| List.repeat flags.codeLength Yellow
        }
