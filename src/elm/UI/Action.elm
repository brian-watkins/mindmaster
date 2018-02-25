module UI.Action exposing
  ( update
  )

import UI.Types exposing (..)
import Game.Types exposing (UseCases)
import UI.Action.EvaluateGuess as EvaluateGuess
import UI.Action.RestartGame as RestartGame
import UI.Action.RecordGuess as RecordGuess
import UI.Action.InputGuess as InputGuess


update : UseCases msg -> Msg -> Model -> (Model, Cmd msg)
update adapters msg model =
  case msg of
    RestartGame ->
      RestartGame.update adapters.restartGame model

    SubmitGuess ->
      EvaluateGuess.update adapters.guessEvaluator model

    ReceivedFeedback guess guessResult ->
      RecordGuess.update guess guessResult model

    GuessInput position guessColor ->
      InputGuess.update position guessColor model

    HighScores scores ->
      ( { model | highScores = scores }, Cmd.none )
