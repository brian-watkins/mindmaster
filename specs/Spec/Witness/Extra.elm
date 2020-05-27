module Spec.Witness.Extra exposing
  ( record
  )

import Runner
import Spec.Witness


record =
  Runner.elmSpecOut
    |> Spec.Witness.connect
    |> Spec.Witness.record