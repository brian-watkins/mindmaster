module IntegrationTestMain exposing (..)

import MindMaster
import CodeGenerator.StaticCodeGenerator as StaticCodeGenerator
import Core.Types exposing (Color(..))
import Core
import UI.Types as View


main : Program Never (Core.Model View.Model) (Core.Msg View.Msg)
main =
  let
    coreAdapters = MindMaster.coreAdapters
  in
    { coreAdapters
    | codeGenerator = StaticCodeGenerator.generator <| List.repeat 5 Yellow
    }
      |> MindMaster.program
