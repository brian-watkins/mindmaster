module UI.Color exposing
  ( toClass
  )

import Game.Types exposing (Color)


toClass : Color -> String
toClass color =
  Basics.toString color
    |> String.toLower
