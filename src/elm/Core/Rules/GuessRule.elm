module Core.Rules.GuessRule exposing
  ( apply
  )

import Core.Code as Code
import Core.Clue as Clue
import Core.Command as Command
import Core.Types exposing (..)


apply : Code -> Code -> GuessFeedback
apply code guess =
  if Code.equals code guess then
    Correct
  else
    clueFor code guess


clueFor : Code -> Code -> GuessFeedback
clueFor code guess =
  let
    correctColors = Code.correctColors code guess
    correctPositions = Code.correctPositions code guess
  in
    Clue.with correctColors correctPositions
      |> Wrong