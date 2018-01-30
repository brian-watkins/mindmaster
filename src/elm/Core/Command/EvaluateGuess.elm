module Core.Command.EvaluateGuess exposing
  ( executor
  )

import Core.Code as Code
import Core.Clue as Clue
import Core.Command as Command
import Core.Types exposing (..)


executor : ((GuessFeedback -> vMsg) -> GuessFeedback -> msg) -> Code -> GuessEvaluator vMsg msg
executor tagger code vTagger guess =
  execute code guess
    |> Command.toCmd (tagger vTagger)


execute : Code -> Code -> GuessFeedback
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
