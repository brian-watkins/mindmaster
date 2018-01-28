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
    let
      correctColors = Code.correctColors code guess
      correctPositions = Code.correctPositions code guess
    in
      Clue.with correctColors correctPositions
        |> Wrong
