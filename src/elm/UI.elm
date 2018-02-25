module UI exposing
  ( defaultModel
  , view
  , update
  , highScoresTagger
  , guessResultTagger
  )

import Html exposing (Html)
import Html.Attributes as Attr
import Game.Types exposing (..)
import UI.Types exposing (..)
import UI.Guess as Guess
import UI.Views.Game as Game
import UI.Views.Instructions as Instructions
import UI.Views.Title as Title
import UI.Views.HighScores as HighScores
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
  , highScores = []
  }


highScoresTagger : List Score -> Msg
highScoresTagger =
  HighScores


guessResultTagger : Code -> GuessResult -> Msg
guessResultTagger =
  ReceivedFeedback


view : GameState -> Model -> Html Msg
view gameState model =
  Html.div []
  [ Title.view
  , Html.div [ Attr.class "row" ]
    [ Instructions.view
    , Game.view gameState model
    , HighScores.view model
    ]
  ]


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
