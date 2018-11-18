module Game.StartGameUseCaseTests exposing (..)

import Test exposing (..)
import Expect
import Elmer
import Elmer.Program as Program
import Elmer.Spy as Spy exposing (Spy, andCallThrough)
import Elmer.Spy.Matchers exposing (wasCalled, wasCalledWith, typedArg)
import Elmer.Command as Command
import Game.TestHelpers exposing (..)
import Game.Types exposing (GameState(..), Color(..))
import Game.Action as Game
import Game.UseCases as UseCases


startGameTests : Test
startGameTests =
  describe "when the start game command is sent" <|
  let
    updateScoreStoreSpy =
      Spy.observe (\_ -> updateScoreStoreFake)
        |> andCallThrough

    codeGeneratorSpy =
      Spy.observe (\_ -> codeGeneratorFake)
        |> andCallThrough

    state =
      Program.givenWorker testUpdateWithHighScores
        |> Spy.use [ updateScoreStoreSpy, codeGeneratorSpy ]
        |> Program.init (\() -> testInit 21 [Orange])
        |> Command.send (\() -> UseCases.evaluateGuess [ Blue ])
        |> Command.send (\() -> UseCases.evaluateGuess [ Green ])
        |> Command.send (\() -> UseCases.startGame <| gameAdaptersWithCodeSpy)
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
  , test "it generates a new code" <|
    \() ->
      state
        |> Spy.expect (\_ -> codeGeneratorFake) (
          wasCalled 1
        )
  , test "it requests the high scores" <|
    \() ->
      state
        |> Spy.expect (\_ -> updateScoreStoreFake) (
          wasCalledWith [ typedArg Nothing ]
        )
  ]


testInit maxGuesses code =
  gameAdaptersWithHighScore code
    |> Game.init { maxGuesses = maxGuesses }


gameAdaptersWithCodeSpy =
  { codeGenerator = Spy.inject (\_ -> codeGeneratorFake)
  , updateScoreStore = (\_ -> Cmd.none)
  , guessResultNotifier = (\guess guessResult -> Cmd.none)
  }


codeGeneratorFake : (List Color -> msg) -> Cmd msg
codeGeneratorFake tagger =
  Command.fake <| tagger [ Blue ]
