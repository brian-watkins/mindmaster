module IntegrationTestMain exposing (..)

import Configuration
import CodeGenerator.StaticCodeGenerator as StaticCodeGenerator
import Core.Types exposing (Color(..))
import Core
import UI.Types as View


main : Program Never (Core.Model View.Model) (Core.Msg View.Msg)
main =
  let
    coreAdapters = Configuration.coreAdapters
  in
    { coreAdapters
    | codeGenerator = StaticCodeGenerator.generator <| List.repeat 5 Yellow
    }
      |> Configuration.program
