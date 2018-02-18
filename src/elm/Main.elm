module Main exposing (..)

import MindMaster
import Core
import UI.Types as View


main : Program Never (Core.Model View.Model) (Core.Msg View.Msg)
main =
  MindMaster.program MindMaster.coreAdapters
