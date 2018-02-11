module UI.Color exposing
  ( toClass
  )

import Core.Types exposing (Color)


toClass : Color -> String
toClass color =
  Basics.toString color
    |> String.toLower
