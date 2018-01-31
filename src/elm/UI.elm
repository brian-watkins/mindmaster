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
import UI.Views.GuessHistory as GuessHistory
import UI.Views.GuessInput as GuessInput
import UI.Views.Outcome as Outcome


defaultModel : Model
defaultModel =
  { guess = Nothing
  , history = []
  }


view : GameState -> Model -> Html Msg
view gameState model =
  case gameState of
    InProgress ->
      Html.div []
      [ GuessInput.view
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
      case model.guess of
        Just guess ->
          ( model, evaluateGuess evaluator guess )
        Nothing ->
          ( model, Cmd.none )
    ReceivedFeedback guess feedback ->
      ( recordGuess model (guess, feedback), Cmd.none )
    GuessInput text ->
      ( { model | guess = Just text }, Cmd.none )


evaluateGuess : GuessEvaluator Msg msg -> String -> Cmd msg
evaluateGuess evaluator guess =
  Code.fromString guess
    |> evaluator (ReceivedFeedback guess)


recordGuess : Model -> (String, GuessFeedback) -> Model
recordGuess model guessRecord =
  { model | history = guessRecord :: model.history }
