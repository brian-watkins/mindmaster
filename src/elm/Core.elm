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
import Core.Actions.GuessCode as GuessCode
import Core.Actions.StartGame as StartGame


type Msg viewMsg
  = SetCode Code
  | Play (GuessFeedback -> viewMsg) Code
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
  , gameState = InProgress maxGuesses
  , maxGuesses = maxGuesses
  , guesses = 0
  , viewModel = vModel
  }


viewModel : Model viewModel -> viewModel
viewModel model =
  model.viewModel


commandForView : Cmd viewMsg -> Cmd (Msg viewMsg)
commandForView =
  Cmd.map ViewMsg


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
      StartGame.update code model

    Play tagger guess ->
      GuessCode.update tagger guess model
        |> mapCommand commandForView

    ViewMsg viewMsg ->
      viewUpdate guessEvaluator viewMsg model.viewModel
        |> mapModel (storeViewModel model)


guessEvaluator : (GuessFeedback -> vmsg) -> Code -> Cmd (Msg vmsg)
guessEvaluator tagger guess =
  Command.toCmd (Play tagger) guess


mapModel : (model -> mapped) -> (model, cmd) -> (mapped, cmd)
mapModel =
  Tuple.mapFirst


mapCommand : (cmd -> mapped) -> (model, cmd) -> (model, mapped)
mapCommand =
  Tuple.mapSecond


storeViewModel : Model viewModel -> viewModel -> Model viewModel
storeViewModel model viewModel =
  { model | viewModel = viewModel }


type alias ViewAdapter viewModel viewMsg =
  GameState -> viewModel -> Html viewMsg

view : ViewAdapter viewModel viewMsg -> Model viewModel -> Html (Msg viewMsg)
view viewAdapter model =
  viewAdapter model.gameState model.viewModel
    |> Html.map ViewMsg
