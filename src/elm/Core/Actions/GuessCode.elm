module Core.Actions.GuessCode exposing
  ( update
  )

import Core.Types exposing (Code, GuessFeedback(..), GameState(..))
import Core.Rules.GuessRule as GuessRule
import Core.Rules.OutcomeRule as OutcomeRule
import Core.Command as Command


type alias Model a =
  { a
  | guesses : Int
  , maxGuesses : Int
  , gameState : GameState
  , code : Code
  }


update : (GuessFeedback -> vmsg) -> Code -> Model a -> (Model a, Cmd vmsg)
update tagger guess model =
  let
    feedback = GuessRule.apply model.code guess
  in
    ( updateModel feedback model
    , Command.toCmd tagger feedback
    )


updateModel : GuessFeedback -> Model a -> Model a
updateModel feedback model =
  { model
  | gameState = OutcomeRule.apply model feedback
  , guesses = model.guesses + 1
  }
