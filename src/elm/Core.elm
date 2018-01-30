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
  , viewModel : vModel
  }


defaultModel : viewModel -> Model viewModel
defaultModel vModel =
  { code = Code.none
  , gameState = InProgress
  , viewModel = vModel
  }


viewModel : Model viewModel -> viewModel
viewModel model =
  model.viewModel

type alias CodeGenerator viewMsg =
  Color -> Code -> Int -> (Code -> Msg viewMsg) -> Cmd (Msg viewMsg)

initGame : CodeGenerator viewMsg -> viewModel -> (Model viewModel, Cmd (Msg viewMsg))
initGame codeGenerator viewModel =
  (defaultModel viewModel, Code.generate SetCode codeGenerator)


type alias ViewUpdate msg model =
  GuessEvaluator msg (Msg msg) -> msg -> model -> (model, Cmd (Msg msg))


update : ViewUpdate viewMsg viewModel -> Msg viewMsg -> Model viewModel -> (Model viewModel, Cmd (Msg viewMsg))
update viewUpdate msg model =
  case msg of
    SetCode code ->
      let
        d = Debug.log "The secret code is" code
      in
        ( { model | code = code, gameState = InProgress }, Cmd.none )

    UpdateGameState tagger feedback ->
      let
        command =
          Command.toCmd tagger feedback
            |> Cmd.map ViewMsg
      in
        case feedback of
          Wrong _ ->
            ( model, command )
          Correct ->
            ( { model | gameState = Won }, command )

    ViewMsg viewMsg ->
      let
        executor = EvaluateGuess.executor UpdateGameState model.code
        ( vmodel, cmd ) = viewUpdate executor viewMsg model.viewModel
      in
        ( { model | viewModel = vmodel }, cmd )


type alias ViewAdapter viewModel viewMsg =
  GameState -> viewModel -> Html viewMsg

view : ViewAdapter viewModel viewMsg -> Model viewModel -> Html (Msg viewMsg)
view viewAdapter model =
  viewAdapter model.gameState model.viewModel
    |> Html.map ViewMsg
