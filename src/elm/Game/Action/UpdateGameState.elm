module Game.Action.UpdateGameState exposing
  ( update
  )

import Game.Types exposing (Code, GuessResult(..), GameState(..))
import Game.Rule.GameStateRule as GameStateRule
import Util.Command as Command


type alias Model a =
  { a
  | guesses : Int
  , maxGuesses : Int
  , gameState : GameState
  , code : Code
  , timer : Int
  }


update : GuessResult -> Model a -> (Model a, Cmd msg)
update guessResult model =
  ( model, Cmd.none )
    |> incrementGuesses
    |> updateGameState guessResult


updateGameState : GuessResult -> (Model a, Cmd msg) -> (Model a, Cmd msg)
updateGameState guessResult =
  Tuple.mapFirst <|
    \model ->
      { model | gameState = GameStateRule.apply model guessResult }


incrementGuesses : (Model a, Cmd msg) -> (Model a, Cmd msg)
incrementGuesses =
  Tuple.mapFirst <|
    \model ->
      { model | guesses = model.guesses + 1 }
