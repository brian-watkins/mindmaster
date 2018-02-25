module Bus exposing
  ( Msg
  , Model
  , init
  , update
  , view
  , subscriptions
  , uiTagger
  )

import Html
import Game
import Game.Action
import Game.Subscriptions
import Game.UseCases
import Util.Command as Command


type Msg uiMsg
  = GameMsg Game.Msg
  | UIMsg uiMsg


type alias Model uiModel =
  { game : Game.Model
  , ui : uiModel
  }


uiTagger =
  UIMsg


init config adapters uiModel =
  Game.Action.init config (gameAdapters adapters)
    |> Tuple.mapFirst (\gameModel -> { game = gameModel, ui = uiModel })


view uiAdapter model =
  uiAdapter (Game.UseCases.gameState model.game) model.ui
    |> Html.map UIMsg


update adapters msg model =
  case msg of
    GameMsg gameMsg ->
      Game.Action.update (gameAdapters adapters) gameMsg model.game
        |> Tuple.mapFirst (\m -> { model | game = m })

    UIMsg uiMsg ->
      adapters.updateUI (uiAdapters adapters) uiMsg model.ui
        |> Tuple.mapFirst (\m -> { model | ui = m })


subscriptions model =
  Game.Subscriptions.for model.game
    |> Sub.map GameMsg


gameAdapters adapters =
  { updateScoreStore =
      adapters.updateScoreStore
  , updateUIWithGuessResult =
      \guess result ->
        Command.toCmd (adapters.guessResultTagger guess) result
          |> Cmd.map UIMsg
  , codeGenerator =
      \tagger ->
        adapters.codeGenerator tagger
          |> Cmd.map GameMsg
  }


uiAdapters adapters =
  { guessEvaluator =
      Game.UseCases.evaluateGuess GameMsg
  , restartGame =
      Game.UseCases.startGame adapters
        |> Cmd.map GameMsg
  }
