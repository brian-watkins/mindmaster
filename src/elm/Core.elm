module Core exposing
  ( Model
  , Msg
  , defaultModel
  , initGame
  , update
  , view
  , viewModel
  , subscriptions
  )

import Html exposing (Html)
import Core.Code as Code
import Core.Clue as Clue
import Core.Command as Command
import Core.Types exposing (..)
import Core.Actions.GuessCode as GuessCode
import Core.Actions.StartGame as StartGame
import Core.Actions.IncrementTimer as IncrementTimer
import Time exposing (Time)


type Msg viewMsg
  = SetCode Code
  | Play (GuessFeedback -> viewMsg) Code
  | ViewMsg viewMsg
  | StartGame ()
  | GameTimer Time


type alias Model vModel =
  { code : Code
  , gameState : GameState
  , maxGuesses : Int
  , guesses : Int
  , viewModel : vModel
  , gameTimer : Int
  }


defaultModel : GameConfig -> viewModel -> Model viewModel
defaultModel config vModel =
  { code = Code.none
  , gameState = InProgress config.maxGuesses
  , maxGuesses = config.maxGuesses
  , guesses = 0
  , viewModel = vModel
  , gameTimer = 0
  }


viewModel : Model viewModel -> viewModel
viewModel model =
  model.viewModel


commandForView : Cmd viewMsg -> Cmd (Msg viewMsg)
commandForView =
  Cmd.map ViewMsg


initGame : GameConfig -> viewModel -> (Model viewModel, Cmd (Msg viewMsg))
initGame config viewModel =
  ( defaultModel config viewModel
  , Command.toCmd StartGame ()
  )


update : CoreAdapters viewMsg viewModel (Msg viewMsg) -> Msg viewMsg -> Model viewModel -> (Model viewModel, Cmd (Msg viewMsg))
update adapters msg model =
  case msg of
    StartGame _ ->
      ( model
      , Code.generate SetCode adapters.codeGenerator
      )

    SetCode code ->
      StartGame.update code model

    GameTimer _ ->
      IncrementTimer.update model

    Play tagger guess ->
      GuessCode.update tagger guess model
        |> mapCommand commandForView

    ViewMsg viewMsg ->
      adapters.viewUpdate viewDependencies viewMsg model.viewModel
        |> mapModel (storeViewModel model)


viewDependencies : ViewDependencies viewMsg (Msg viewMsg)
viewDependencies =
  { guessEvaluator = guessEvaluator
  , restartGameCommand = Command.toCmd StartGame ()
  }


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


subscriptions : Model viewModel -> Sub (Msg viewMsg)
subscriptions model =
  case model.gameState of
    InProgress _ ->
      Time.every Time.second GameTimer
    _ ->
      Sub.none
