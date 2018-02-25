module Game.Action.JudgeGuess exposing
  ( update
  )

import Game.Types exposing (Code, GameState(..))
import Game.Action.UpdateGameState as UpdateGameState
import Game.Rule.GuessRule as GuessRule
import Util.Command as Command


type alias Model a =
  { a
  | guesses : Int
  , maxGuesses : Int
  , gameState : GameState
  , code : Code
  , timer : Int
  }


update adapters guess model =
  let
    guessResult = GuessRule.apply model.code guess
  in
    UpdateGameState.update guessResult model
      |> sendGuessResultToUI adapters.updateUIWithGuessResult guess guessResult
      |> refreshScores adapters.updateScoreStore


sendGuessResultToUI guessResultCommand guess guessResult =
  Tuple.mapSecond <|
    \cmd ->
      guessResultCommand guess guessResult
        |> Command.add cmd


refreshScores updateScores (model, cmd) =
  case model.gameState of
    Won score ->
      ( model
      , Command.add cmd <| updateScores <| Just score
      )
    _ ->
      ( model, cmd )
