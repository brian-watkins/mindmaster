port module Runner exposing
  ( program
  )

import Spec.Runner
import Spec.Message exposing (Message)


port elmSpecOut : Message -> Cmd msg
port elmSpecIn : (Message -> msg) -> Sub msg


config : Spec.Runner.Config msg
config =
  { send = elmSpecOut
  , outlet = elmSpecOut
  , listen = elmSpecIn
  }


program specs =
  Spec.Runner.browserProgram config specs