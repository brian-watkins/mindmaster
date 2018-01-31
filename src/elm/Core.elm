module Core exposing
  ( Model
  , Msg
  , defaultModel
  , initGame
  , update
  , view
  , viewModel
  )

import Html exposing (Html)
import Core.Code as Code
import Core.Clue as Clue
import Core.Command as Command
import Core.Types exposing (..)
import Core.Command.EvaluateGuess as EvaluateGuess


type Msg viewMsg
  = SetCode Code
  | UpdateGameState (GuessFeedback -> viewMsg) GuessFeedback
  | ViewMsg viewMsg


type alias Model vModel =
  { code : Code
  , gameState : GameState
  , maxGuesses : Int
  , guesses : Int
  , viewModel : vModel
  }


defaultModel : Int -> viewModel -> Model viewModel
defaultModel maxGuesses vModel =
  { code = Code.none
  , gameState = InProgress
  , maxGuesses = maxGuesses
  , guesses = 0
  , viewModel = vModel
  }


viewModel : Model viewModel -> viewModel
viewModel model =
  model.viewModel


initGame : GameConfig (Msg viewMsg) -> viewModel -> (Model viewModel, Cmd (Msg viewMsg))
initGame config viewModel =
  ( defaultModel config.maxGuesses viewModel
  , Code.generate SetCode config.codeGenerator
  )


type alias ViewUpdate msg model =
  GuessEvaluator msg (Msg msg) -> msg -> model -> (model, Cmd (Msg msg))


update : ViewUpdate viewMsg viewModel -> Msg viewMsg -> Model viewModel -> (Model viewModel, Cmd (Msg viewMsg))
update viewUpdate msg model =
  case msg of
    SetCode code ->
      startGame code model

    UpdateGameState tagger feedback ->
      ( updateGameState feedback model
      , Cmd.map ViewMsg <| Command.toCmd tagger feedback
      )

    ViewMsg viewMsg ->
      EvaluateGuess.executor UpdateGameState model.code
        |> configure viewUpdate viewMsg model.viewModel
        |> mapToModel model


startGame : Code -> Model viewModel -> ( Model viewModel, Cmd msg )
startGame code model =
  ( { model | code = code, gameState = InProgress }, Cmd.none )


configure : ( a -> b -> c -> d ) -> b -> c -> a -> d
configure func b c a =
  func a b c


mapToModel : Model viewModel -> ( viewModel, Cmd msg ) -> ( Model viewModel, Cmd msg )
mapToModel model ( viewModel, command ) =
  ( { model | viewModel = viewModel }, command )


updateGameState : GuessFeedback -> Model viewModel -> Model viewModel
updateGameState feedback model =
  case feedback of
    Wrong _ ->
      if model.guesses + 1 == model.maxGuesses then
        { model | gameState = Lost model.code }
      else
        { model | guesses = model.guesses + 1 }
    Correct ->
      { model | gameState = Won }


type alias ViewAdapter viewModel viewMsg =
  GameState -> viewModel -> Html viewMsg

view : ViewAdapter viewModel viewMsg -> Model viewModel -> Html (Msg viewMsg)
view viewAdapter model =
  viewAdapter model.gameState model.viewModel
    |> Html.map ViewMsg
