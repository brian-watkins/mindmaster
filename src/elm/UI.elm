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


defaultModel : Model
defaultModel =
  { guess = Guess.none
  , history = []
  }


view : GameState -> Model -> Html Msg
view gameState model =
  case gameState of
    InProgress ->
      Html.div []
      [ GuessInput.view model
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
      ( { model | guess = Guess.none }, evaluateGuess evaluator model.guess )
    ReceivedFeedback guess feedback ->
      ( recordGuess model (guess, feedback), Cmd.none )
    GuessInput position guessColor ->
      ( { model | guess = Guess.with position guessColor model.guess }, Cmd.none )


evaluateGuess : GuessEvaluator Msg msg -> Guess -> Cmd msg
evaluateGuess evaluator guess =
  let
    guessedCode =
      Guess.toCode guess
  in
    evaluator (ReceivedFeedback guessedCode) guessedCode


recordGuess : Model -> (Code, GuessFeedback) -> Model
recordGuess model guessRecord =
  { model | history = guessRecord :: model.history }
