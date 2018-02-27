module Game.Entity.Clue exposing
  ( with
  )

import Game.Types exposing (..)


with : Int -> Int -> Clue
with colors positions =
  { colors = colors
  , positions = positions
  }
