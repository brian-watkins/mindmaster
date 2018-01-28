module Core.Command.EvaluateGuess exposing
  ( execute
  )

import Core.Code as Code
import Core.Clue as Clue
import Core.Types exposing (GuessFeedback(..), Color(..))

execute : List Color -> List Color -> GuessFeedback
execute code guess =
  if Code.equals code guess then
    Correct
  else
    Code.correctColors code guess
      |> Clue.withColorsCorrect
      |> Wrong
