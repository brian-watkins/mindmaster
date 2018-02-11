module UI exposing
  ( defaultModel
  , view
  , update
  )

import Html exposing (Html)
import Core.Types exposing (..)
import UI.Types exposing (..)
import UI.Guess as Guess
import UI.Views.GuessHistory as GuessHistory
import UI.Views.GuessInput as GuessInput
import UI.Views.Outcome as Outcome
import UI.Views.Progress as Progress
import UI.Actions.EvaluateGuess as EvaluateGuess
import UI.Actions.RestartGame as RestartGame
import UI.Actions.RecordGuess as RecordGuess
import UI.Actions.InputGuess as InputGuess


type alias UIConfig =
  { codeLength : Int
  , colors : List Color
  }


defaultModel : UIConfig -> Model
defaultModel config =
  { guess = Guess.empty config.codeLength
  , history = []
  , codeLength = config.codeLength
  , validation = Valid
  , attempts = 0
  , colors = config.colors
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


update : ViewDependencies Msg msg -> Msg -> Model -> (Model, Cmd msg)
update dependencies msg model =
  case msg of
    RestartGame ->
      RestartGame.update dependencies.restartGameCommand model

    SubmitGuess ->
      EvaluateGuess.update
        dependencies.guessEvaluator
        (feedbackTagger model.guess)
        model

    ReceivedFeedback guess feedback ->
      RecordGuess.update guess feedback model

    GuessInput position guessColor ->
      InputGuess.update position guessColor model


feedbackTagger : Guess -> GuessFeedback -> Msg
feedbackTagger guess =
  ReceivedFeedback <| Guess.toCode guess
