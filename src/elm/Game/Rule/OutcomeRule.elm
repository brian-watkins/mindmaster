module Game.Rule.OutcomeRule exposing
  ( apply
  )

import Game.Types exposing (..)
import Game.Rule.ScoringRule as ScoringRule


type alias Model a =
  { a
  | guesses : Int
  , maxGuesses : Int
  , code : Code
  , timer : Int
  }

apply : Model a -> GuessResult -> GameState
apply model guessResult =
  case guessResult of
    Wrong _ ->
      if model.guesses == model.maxGuesses then
        Lost model.code
      else
        InProgress (model.maxGuesses - model.guesses)
    Right ->
      ScoringRule.apply model
        |> Won
