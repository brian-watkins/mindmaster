module Game.Actions.UpdateGameState exposing
  ( update
  )

import Game.Types exposing (Code, GuessResult(..), GameState(..))
import Game.Rules.OutcomeRule as OutcomeRule
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
updateGameState guessResult (model, cmd) =
  ( { model | gameState = OutcomeRule.apply model guessResult }
  , cmd
  )


incrementGuesses : (Model a, Cmd msg) -> (Model a, Cmd msg)
incrementGuesses (model, cmd) =
  ( { model | guesses = model.guesses + 1 }
  , cmd
  )
