module Game.EvaluateGuessUseCaseTests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Elmer
import Elmer.Program as Program
import Elmer.Command as Command
import Elmer.Spy as Spy exposing (Spy)
import Elmer.Spy.Matchers exposing (wasCalledWith, typedArg)
import Game.Entity.Clue as Clue
import Game.TestHelpers exposing (..)
import Game.Types exposing (Code, GameState(..), Color(..), GuessResult(..))
import Game.Action as Game
import Game.UseCases as UseCases


evaluateGuessTests : Test
evaluateGuessTests =
  describe "evaluate guess"
  [ describe "when no colors are correct"
    [ test "it returns a clue with 0 colors correct" <|
      \() ->
        expectGuessResult [ Blue ] [ Green ] <|
          wrong 0 0
    ]
  , describe "when only one color is correct"
    [ test "it returns a clue with 1 color correct" <|
      \() ->
        expectGuessResult [ Blue, Red ] [ Yellow, Blue ] <|
          wrong 1 0
    ]
  , describe "when there are matching identical colors in the guess"
    [ test "it should only match the number in the code" <|
      \() ->
        expectGuessResult [ Blue, Blue, Yellow, Blue, Orange ] [ Green, Red, Blue, Red, Blue ] <|
          wrong 2 0
    ]
  , describe "when more than one color is correct"
    [ test "it returns a clue with the right number of correct colors" <|
      \() ->
        expectGuessResult [ Blue, Yellow, Red ] [ Yellow, Blue, Green ] <|
          wrong 2 0
    ]
  , describe "when one color is in the right position"
    [ test "it returns a clue with one in the right position" <|
      \() ->
        expectGuessResult [ Blue, Yellow, Yellow ] [ Green, Yellow, Blue ] <|
          wrong 2 1
    ]
  , describe "when more than one color is in the right position"
    [ test "it returns a clue with the number in the right position" <|
      \() ->
        expectGuessResult [ Blue, Yellow, Yellow ] [ Green, Yellow, Yellow ] <|
          wrong 2 2
    ]
  , describe "when the guess is correct"
    [ test "it says the guess is Right" <|
      \() ->
        expectGuessResult [ Blue, Yellow, Yellow ] [ Blue, Yellow, Yellow ] <|
          Right
    ]
  ]


expectGuessResult : Code -> Code -> GuessResult -> Expectation
expectGuessResult code guess expectedGuessResult =
  Program.givenWorker testUpdateWithGuessResultNotifier
    |> Spy.use [ guessResultSpy ]
    |> Program.init (\_ -> testInit 5 code)
    |> Command.send (\() -> UseCases.evaluateGuess guess)
    |> Spy.expect (\_ -> guessResultFake) (
      wasCalledWith
        [ typedArg guess
        , typedArg expectedGuessResult
        ]
    )


wrong : Int -> Int -> GuessResult
wrong colorsCorrect positionsCorrect =
  Clue.with colorsCorrect positionsCorrect
    |> Wrong


guessResultSpy : Spy
guessResultSpy =
  Spy.observe (\_ -> guessResultFake)
    |> Spy.andCallThrough

guessResultFake : a -> b -> Cmd msg
guessResultFake _ _ =
  Cmd.none


testUpdateWithGuessResultNotifier =
  let
    adapters = gameAdapters []
  in
    { adapters | guessResultNotifier = Spy.inject (\_ -> guessResultFake) }
      |> Game.update
