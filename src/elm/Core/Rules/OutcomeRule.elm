module Core.Rules.OutcomeRule exposing
  ( apply
  )

import Core.Types exposing (..)

type alias Model a =
  { a
  | guesses : Int
  , maxGuesses : Int
  , code : Code
  , gameTimer : Int
  }

apply : Model a -> GuessResult -> GameState
apply model guessResult =
  case guessResult of
    Wrong _ ->
      if model.guesses + 1 == model.maxGuesses then
        Lost model.code
      else
        InProgress (model.maxGuesses - model.guesses - 1)
    Right ->
      model.gameTimer + ((model.guesses + 1) * 50)
        |> Won
