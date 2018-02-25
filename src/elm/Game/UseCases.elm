module Game.UseCases exposing
  ( startGame
  , evaluateGuess
  , gameState
  )

import Game exposing (..)
import Game.Types exposing (GameState, Code)
import Util.Command as Command


gameState : Model -> GameState
gameState model =
  model.gameState


startGame adapters =
  adapters.codeGenerator Start


evaluateGuess : Code -> Cmd Msg
evaluateGuess code =
  Command.toCmd Judge code
