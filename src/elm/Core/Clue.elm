module Core.Clue exposing
  ( withColorsCorrect
  )

import Core.Types exposing (..)

withColorsCorrect : Int -> Clue
withColorsCorrect num =
  { colors = num
  }
