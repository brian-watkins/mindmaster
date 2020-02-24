port module Runner exposing
  ( program
  , pick
  )

import Spec.Runner exposing (Message)


port elmSpecOut : Message -> Cmd msg
port elmSpecIn : (Message -> msg) -> Sub msg
port elmSpecPick : () -> Cmd msg


config : Spec.Runner.Config msg
config =
  { send = elmSpecOut
  , outlet = elmSpecOut
  , listen = elmSpecIn
  }


pick =
  Spec.Runner.pick elmSpecPick


program specs =
  Spec.Runner.browserProgram config specs