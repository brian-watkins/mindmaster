module Game.Actions.JudgeGuess exposing
  ( update
  )

import Game.Types exposing (Code, GameState(..))
import Game.Actions.UpdateGameState as UpdateGameState
import Game.Rules.GuessRule as GuessRule


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


sendGuessResultToUI guessResultCommand guess guessResult (model, cmd) =
  (model
  , Cmd.batch
    [ cmd, guessResultCommand guess guessResult
    ]
  )


refreshScores updateScores (model, cmd) =
  case model.gameState of
    Won score ->
      (model, Cmd.batch [ cmd, updateScores <| Just score ])
    _ ->
      (model, cmd)
