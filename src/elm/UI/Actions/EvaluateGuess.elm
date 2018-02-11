module UI.Actions.EvaluateGuess exposing
  ( update
  )

import Core.Types exposing (GuessEvaluator, GuessFeedback)
import UI.Types exposing (Guess, Validation(..))
import UI.Guess as Guess


type alias Model a =
  { a
  | guess : Guess
  , codeLength : Int
  , validation : Validation
  , attempts : Int
  }


type alias FeedbackTagger msg =
  GuessFeedback -> msg


update : GuessEvaluator viewMsg msg -> FeedbackTagger viewMsg -> Model a -> ( Model a, Cmd msg )
update evaluator feedbackTagger model =
  if isGuessComplete model then
    ( { model
      | validation = GuessIncomplete
      , attempts = model.attempts + 1
      }
    , Cmd.none
    )
  else
    ( { model
      | guess = Guess.none
      , validation = Valid
      , attempts = 0
      }
    , evaluateGuess evaluator feedbackTagger model.guess
    )


isGuessComplete : Model a -> Bool
isGuessComplete model =
  Guess.lengthSelected model.guess < model.codeLength


evaluateGuess : GuessEvaluator viewMsg msg -> FeedbackTagger viewMsg -> Guess -> Cmd msg
evaluateGuess evaluator feedbackTagger guess =
  Guess.toCode guess
    |> evaluator feedbackTagger
