module Game.GameStateUseCaseTests exposing (..)

import Test exposing (..)
import Expect
import Elmer exposing (TestState)
import Elmer.Headless as Headless
import Elmer.Spy as Spy
import Elmer.Spy.Matchers exposing (wasCalledWith, typedArg)
import Elmer.Platform.Command as Command
import Elmer.Platform.Subscription as Subscription
import TestHelpers
import Game.TestHelpers exposing (..)
import Game.Types exposing (GameState(..), Color(..))
import Game.Action as Game
import Game.UseCases as UseCases
import Game.Subscriptions


gameStateTests : Test
gameStateTests =
  describe "game state"
  [ describe "when the page loads"
    [ test "it reports the GameState to be InProgress with the max remaining guesses" <|
      \() ->
        Headless.given testModel (testUpdate [ Orange ])
          |> Elmer.init (\_ -> testInit 21 [ Orange ])
          |> Elmer.expectModel (\model ->
            UseCases.gameState model
              |> Expect.equal (InProgress 21)
          )
    ]
  , describe "when the guess is wrong"
    [ test "it decreases the number of remaining guesses by one" <|
      \() ->
        Headless.given testModel (testUpdate [ Orange ])
          |> Elmer.init (\_ -> testInit 21 [ Orange ])
          |> Command.send (\() -> UseCases.evaluateGuess [ Blue ])
          |> Command.send (\() -> UseCases.evaluateGuess [ Green ])
          |> Command.send (\() -> UseCases.evaluateGuess [ Red ])
          |> Elmer.expectModel (\model ->
            UseCases.gameState model
              |> Expect.equal (InProgress 18)
          )
    ]
  , describe "when the guess is correct" <|
    [ test "it reports the GameState to be Won" <|
      \() ->
        Headless.given testModel (testUpdate [ Orange ])
          |> Elmer.init (\_ -> testInit 21 [ Orange ])
          |> Command.send (\() -> UseCases.evaluateGuess [ Orange ])
          |> Elmer.expectModel (\model ->
            case UseCases.gameState model of
              Won _ ->
                Expect.pass
              _ ->
                Expect.fail "GameState should be Won"
          )
    ]
  , describe "when the max number of incorrect answers has been given"
    [ test "it reports the game state of Lost along with the code" <|
      \() ->
        Headless.given testModel (testUpdate [ Orange ])
          |> Elmer.init (\_ -> testInit 2 [ Orange ])
          |> Command.send (\() -> UseCases.evaluateGuess [ Blue ])
          |> Command.send (\() -> UseCases.evaluateGuess [ Green ])
          |> Elmer.expectModel (\model ->
            UseCases.gameState model
              |> Expect.equal (Lost [ Orange ])
          )
    ]
  ]


scoreTests : Test
scoreTests =
  describe "when the guess is correct"
  [ describe "when one correct guess is made after a few seconds" <|
    let
      state =
        Headless.given testModel (testUpdateWithHighScores [ Orange ])
          |> Spy.use [ timeSpy, updateScoreStoreSpy ]
          |> Elmer.init (\_ -> testInit 2 [ Orange ])
          |> Subscription.with (\_ -> Game.Subscriptions.for)
          |> Subscription.send "time-sub" 1
          |> Subscription.send "time-sub" 1
          |> Subscription.send "time-sub" 1
          |> Subscription.send "time-sub" 1
          |> Command.send (\() -> UseCases.evaluateGuess [ Orange ])
    in
    [ test "the score is 50 plus the number of seconds" <|
      \() ->
        state
          |> Elmer.expectModel (\model ->
            UseCases.gameState model
              |> Expect.equal (Won 54)
          )
    , test "it saves the score" <|
      \() ->
        state
          |> Spy.expect "update-score-store-spy" (
            wasCalledWith [ typedArg <| Just 54 ]
          )
    ]
  , describe "when more than one incorrect guess is made after a few seconds" <|
    let
      state =
        Headless.given testModel (testUpdateWithHighScores [ Orange ])
          |> Spy.use [ timeSpy, updateScoreStoreSpy ]
          |> Elmer.init (\_ -> testInit 10 [ Orange ])
          |> Subscription.with (\_ -> Game.Subscriptions.for)
          |> elapseSeconds 4
          |> Command.send (\() -> UseCases.evaluateGuess [ Red ])
          |> elapseSeconds 3
          |> Command.send (\() -> UseCases.evaluateGuess [ Green ])
          |> elapseSeconds 6
          |> Command.send (\() -> UseCases.evaluateGuess [ Orange ])
    in
    [ test "the score is 50 * number of guesses plus number of seconds" <|
      \() ->
        state
          |> Elmer.expectModel (\model ->
            UseCases.gameState model
              |> Expect.equal (Won 163)
          )
    , test "it saves the score" <|
      \() ->
        state
          |> Spy.expect "update-score-store-spy" (
            wasCalledWith [ typedArg <| Just 163 ]
          )
    ]
  ]


elapseSeconds : Int -> TestState model msg -> TestState model msg
elapseSeconds seconds testState =
  (\state -> Subscription.send "time-sub" 1 state)
    |> List.repeat seconds
    |> TestHelpers.foldStates testState
