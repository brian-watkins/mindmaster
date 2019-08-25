module Configuration.Bus exposing
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
import Procedure.Program
import Procedure


type Msg uiMsg
  = GameMsg Game.Msg
  | UIMsg uiMsg
  | ProcedureMsg (Procedure.Program.Msg (Msg uiMsg))


type alias Model uiModel uiMsg =
  { game : Game.Model
  , ui : uiModel
  , procedureModel : Procedure.Program.Model (Msg uiMsg)
  }


uiTagger =
  UIMsg


init config adapters uiModel =
  Game.Action.init config (gameAdapters adapters)
    |> Tuple.mapFirst (\gameModel -> { game = gameModel, ui = uiModel, procedureModel = Procedure.Program.init })


view uiAdapter model =
  uiAdapter (Game.UseCases.gameState model.game) model.ui
    |> Html.map UIMsg


update adapters msg model =
  case msg of
    GameMsg gameMsg ->
      Game.Action.update (gameAdapters adapters) gameMsg model.game
        |> storeGameModel model

    UIMsg uiMsg ->
      adapters.updateUI (uiAdapters adapters) uiMsg model.ui
        |> storeUIModel model

    ProcedureMsg pMsg ->
      Procedure.Program.update pMsg model.procedureModel
        |> Tuple.mapFirst (\updated -> { model | procedureModel = updated })


subscriptions model =
  Sub.batch
  [ Game.Subscriptions.for model.game
      |> Sub.map GameMsg
  , Procedure.Program.subscriptions model.procedureModel
  ]


gameAdapters adapters =
  { updateScoreStore =
      \maybeScore ->
        adapters.updateScoreStore maybeScore
          |> Procedure.run ProcedureMsg (UIMsg << adapters.displayScores)
  , guessResultNotifier =
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
      \guess ->
        Game.UseCases.evaluateGuess guess
          |> Cmd.map GameMsg
  , restartGame =
      Game.UseCases.startGame adapters
        |> Cmd.map GameMsg
  }


storeGameModel model =
  Tuple.mapFirst (\m -> { model | game = m })


storeUIModel model =
  Tuple.mapFirst (\m -> { model | ui = m })
