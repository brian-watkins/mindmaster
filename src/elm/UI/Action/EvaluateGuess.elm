module UI.Action.EvaluateGuess exposing
  ( update
  )

import Game.Types exposing (GuessEvaluator, GuessResult)
import UI.Types exposing (Guess, Validation(..))
import UI.Entity.Guess as Guess


type alias Model a =
  { a
  | guess : Guess
  , codeLength : Int
  , validation : Validation
  , attempts : Int
  }


type alias FeedbackTagger msg =
  GuessResult -> msg


update : GuessEvaluator msg -> Model a -> ( Model a, Cmd msg )
update evaluator model =
  if isGuessComplete model then
    ( { model
      | validation = GuessIncomplete
      , attempts = model.attempts + 1
      }
    , Cmd.none
    )
  else
    ( { model
      | guess = Guess.empty model.codeLength
      , validation = Valid
      , attempts = 0
      }
    , evaluateGuess evaluator model.guess
    )


isGuessComplete : Model a -> Bool
isGuessComplete model =
  Guess.lengthSelected model.guess < model.codeLength


evaluateGuess : GuessEvaluator msg -> Guess -> Cmd msg
evaluateGuess evaluator guess =
  Guess.toCode guess
    |> evaluator
