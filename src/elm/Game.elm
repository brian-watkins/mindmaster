module Game exposing
  ( Msg
  , Model
  , init
  , update
  , subscriptions
  , startGame
  , evaluateGuess
  , gameState
  )

import Game.Types exposing (GameConfig, Code, GameState(..))
import Game.Code as Code
import Game.Actions.StartGame as StartGame
import Game.Actions.IncrementTimer as IncrementTimer
import Game.Actions.JudgeGuess as JudgeGuess
import Util.Command as Command
import Time exposing (Time)


type Msg
  = Start Code
  | Judge Code
  | IncrementTimer Time


type alias Model =
  { code : Code
  , gameState : GameState
  , maxGuesses : Int
  , guesses : Int
  , timer : Int
  }


defaultModel : GameConfig -> Model
defaultModel config =
  { code = Code.none
  , gameState = InProgress config.maxGuesses
  , maxGuesses = config.maxGuesses
  , guesses = 0
  , timer = 0
  }


init config adapters =
  ( defaultModel config
  , Cmd.batch
    [ adapters.codeGenerator Start
    , adapters.updateScoreStore Nothing
    ]
  )


gameState : Model -> GameState
gameState model =
  model.gameState


startGame adapters =
  adapters.codeGenerator Start


evaluateGuess : (Msg -> msg) -> Code -> Cmd msg
evaluateGuess tagger code =
  Command.toCmd Judge code
    |> Cmd.map tagger


update adapters msg model =
  case msg of
    Start code ->
      StartGame.update code model

    Judge guess ->
      JudgeGuess.update adapters guess model

    IncrementTimer _ ->
      IncrementTimer.update model


subscriptions : Model -> Sub Msg
subscriptions model =
  case model.gameState of
    InProgress _ ->
      Time.every Time.second IncrementTimer
    _ ->
      Sub.none
