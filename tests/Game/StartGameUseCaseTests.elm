module Game.StartGameUseCaseTests exposing (..)

import Test exposing (..)
import Expect
import Elmer
import Elmer.Headless as Headless
import Elmer.Spy as Spy exposing (Spy)
import Elmer.Spy.Matchers exposing (wasCalled, wasCalledWith, typedArg)
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
      Headless.given testModel testUpdateWithHighScores
        |> Spy.use [ updateScoreStoreSpy, codeGeneratorSpy ]
        |> Elmer.init (\() -> testInit 21 [Orange])
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
        |> Spy.expect "code-generator-spy" (
          wasCalled 1
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


gameAdaptersWithCodeSpy =
  { codeGenerator = Spy.callable "code-generator-spy"
  , updateScoreStore = (\_ -> Cmd.none)
  , guessResultNotifier = (\guess guessResult -> Cmd.none)
  }


codeGeneratorSpy : Spy
codeGeneratorSpy =
  Spy.createWith "code-generator-spy" <|
    \tagger ->
      Command.fake <| tagger [ Blue ]
