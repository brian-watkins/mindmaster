module UI.Entity.Color exposing
  ( toClass
  )

import Game.Types exposing (Color(..))


toClass : Color -> String
toClass color =
  case color of
    None -> "none"
    Red -> "red"
    Orange -> "orange"
    Yellow -> "yellow"
    Green -> "green"
    Blue -> "blue"
