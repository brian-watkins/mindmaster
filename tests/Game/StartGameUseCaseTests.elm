module Game.StartGameUseCaseTests exposing (..)

import Test exposing (..)
import Expect
import Elmer
import Elmer.Headless as Headless
import Elmer.Spy as Spy
import Elmer.Spy.Matchers exposing (wasCalledWith, typedArg)
import Elmer.Platform.Command as Command
import Game.TestHelpers exposing (..)
import Game.Types exposing (GameState(..), Color(..))
import Game.Action as Game
import Game.UseCases as UseCases


startGameTests : Test
startGameTests =
  describe "when the start game command is sent" <|
  let
    state =
      Headless.given testModel (testUpdateWithHighScores [ Orange ])
        |> Spy.use [ updateScoreStoreSpy ]
        |> Elmer.init (\() -> testInit 21 [Orange])
        |> Command.send (\() -> UseCases.evaluateGuess [ Blue ])
        |> Command.send (\() -> UseCases.evaluateGuess [ Green ])
        |> Command.send (\() -> UseCases.startGame <| gameAdapters [ Blue ])
  in
  [ test "it restarts the game" <|
    \() ->
      state
        |> Elmer.expectModel (\model ->
          UseCases.gameState model
            |> Expect.equal (InProgress 21)
        )
  , test "it resets the number of guesses to zero" <|
    \() ->
      state
        |> Command.send (\() -> UseCases.evaluateGuess [ Green ])
        |> Elmer.expectModel (\model ->
          UseCases.gameState model
            |> Expect.equal (InProgress 20)
        )
  , test "it requests the high scores" <|
    \() ->
      state
        |> Spy.expect "update-score-store-spy" (
          wasCalledWith [ typedArg Nothing ]
        )
  ]


testInit maxGuesses code =
  gameAdaptersWithHighScore code
    |> Game.init { maxGuesses = maxGuesses }
