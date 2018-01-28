module Core.Clue exposing
  ( with
  )

import Core.Types exposing (..)


with : Int -> Int -> Clue
with colors positions =
  { colors = colors
  , positions = positions
  }
