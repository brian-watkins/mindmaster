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


evaluateGuess : (Msg -> msg) -> Code -> Cmd msg
evaluateGuess tagger code =
  Command.toCmd Judge code
    |> Cmd.map tagger
