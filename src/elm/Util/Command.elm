module Util.Command exposing
  ( toCmd
  , add
  )

import Task


toCmd : (a -> msg) -> a -> Cmd msg
toCmd tagger value =
  Task.succeed value
    |> Task.perform tagger


add : Cmd msg -> Cmd msg -> Cmd msg
add cmd anotherCmd =
  Cmd.batch
  [ cmd
  , anotherCmd
  ]
