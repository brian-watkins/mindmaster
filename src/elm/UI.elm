module UI exposing
  ( defaultModel
  , view
  , update
  )

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Core.Types exposing (..)
import UI.Types exposing (..)
import UI.Code as Code
import UI.Guess as Guess
import UI.Views.GuessHistory as GuessHistory
import UI.Views.GuessInput as GuessInput
import UI.Views.Outcome as Outcome
import UI.Views.Progress as Progress
import UI.Actions.EvaluateGuess as EvaluateGuess


type alias UIConfig =
  { codeLength : Int
  }


defaultModel : UIConfig -> Model
defaultModel config =
  { guess = Guess.none
  , history = []
  , codeLength = config.codeLength
  , validation = Valid
  , attempts = 0
  }


view : GameState -> Model -> Html Msg
view gameState model =
  case gameState of
    InProgress remainingGuesses ->
      Html.div []
      [ GuessInput.view model
      , Progress.view remainingGuesses
      , GuessHistory.view model
      ]
    Won ->
      Html.div []
      [ Outcome.view Win
      , GuessHistory.view model
      ]
    Lost code ->
      Html.div []
      [ Outcome.view <| Loss code
      , GuessHistory.view model
      ]


update : GuessEvaluator Msg msg -> Msg -> Model -> (Model, Cmd msg)
update evaluator msg model =
  case msg of
    SubmitGuess ->
      EvaluateGuess.update
        evaluator
        (feedbackTagger model.guess)
        model

    ReceivedFeedback guess feedback ->
      ( recordGuess model (guess, feedback)
      , Cmd.none
      )

    GuessInput position guessColor ->
      ( { model | guess = Guess.with position guessColor model.guess }
      , Cmd.none
      )


feedbackTagger : Guess -> GuessFeedback -> Msg
feedbackTagger guess =
  ReceivedFeedback <| Guess.toCode guess


recordGuess : Model -> (Code, GuessFeedback) -> Model
recordGuess model guessRecord =
  { model | history = guessRecord :: model.history }
