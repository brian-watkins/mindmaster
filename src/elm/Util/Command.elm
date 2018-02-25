module Util.Command exposing
  ( toCmd
  )

import Task


toCmd : (a -> msg) -> a -> Cmd msg
toCmd tagger value =
  Task.succeed value
    |> Task.perform tagger
