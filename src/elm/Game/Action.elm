module Game.Action exposing
  ( init
  , update
  )

import Game exposing (..)
import Game.Action.StartGame as StartGame
import Game.Action.IncrementTimer as IncrementTimer
import Game.Action.JudgeGuess as JudgeGuess
import Game.Entity.Code as Code
import Game.Types exposing (GameConfig, GameState(..))


update adapters msg model =
  case msg of
    Start code ->
      StartGame.update code model

    Judge guess ->
      JudgeGuess.update adapters guess model

    IncrementTimer _ ->
      IncrementTimer.update model


init config adapters =
  ( defaultModel config
  , Cmd.batch
    [ adapters.codeGenerator Start
    , adapters.updateScoreStore Nothing
    ]
  )


defaultModel : GameConfig -> Model
defaultModel config =
  { code = Code.none
  , gameState = InProgress config.maxGuesses
  , maxGuesses = config.maxGuesses
  , guesses = 0
  , timer = 0
  }
