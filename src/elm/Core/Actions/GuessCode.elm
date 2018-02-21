module Core.Actions.GuessCode exposing
  ( update
  )

import Core.Types exposing (Code, GuessResult(..), GameState(..))
import Core.Rules.GuessRule as GuessRule
import Core.Rules.OutcomeRule as OutcomeRule
import Core.Command as Command


type alias Model a =
  { a
  | guesses : Int
  , maxGuesses : Int
  , gameState : GameState
  , code : Code
  , gameTimer : Int
  }


update : (GuessResult -> vmsg) -> Code -> Model a -> (Model a, Cmd vmsg)
update tagger guess model =
  let
    guessResult = GuessRule.apply model.code guess
  in
    ( updateModel guessResult model
    , Command.toCmd tagger guessResult
    )


updateModel : GuessResult -> Model a -> Model a
updateModel guessResult model =
  { model
  | gameState = OutcomeRule.apply model guessResult
  , guesses = model.guesses + 1
  }
