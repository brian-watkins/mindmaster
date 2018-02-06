module Core.Rules.OutcomeRule exposing
  ( apply
  )

import Core.Types exposing (..)

type alias Model a =
  { a
  | guesses : Int
  , maxGuesses : Int
  , code : Code
  }

apply : Model a -> GuessFeedback -> GameState
apply model feedback =
  case feedback of
    Wrong _ ->
      if model.guesses + 1 == model.maxGuesses then
        Lost model.code
      else
        InProgress (model.maxGuesses - model.guesses - 1)
    Correct ->
      Won
