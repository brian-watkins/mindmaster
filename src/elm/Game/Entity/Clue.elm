module Game.Entity.Clue exposing
  ( with
  , for
  )

import Game.Types exposing (..)
import Game.Entity.Code as Code


with : Int -> Int -> Clue
with colors positions =
  { colors = colors
  , positions = positions
  }


for : Code -> Code -> Clue
for code guess =
  with
    (Code.correctColors code guess)
    (Code.correctPositions code guess)
