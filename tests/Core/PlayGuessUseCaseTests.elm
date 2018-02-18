module Core.PlayGuessUseCaseTests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Elmer exposing (TestState)
import Elmer.Html as Markup
import Elmer.Html.Event as Event
import Elmer.Html.Matchers exposing (element, hasText)
import Elmer.Spy as Spy exposing (Spy, andCallFake)
import Elmer.Spy.Matchers exposing (wasCalledWith, typedArg, anyArg)
import Elmer.Platform.Command as Command
import Elmer.Platform.Subscription as Subscription
import TestHelpers
import Core
import Core.Clue as Clue
import Core.Types exposing (..)
import Core.Fakes.FakeUI as FakeUI
import Core.Fakes.FakeCodeGenerator as FakeCodeGenerator
import Core.TestHelpers as CoreHelpers
import Time


gameStateTests : Test
gameStateTests =
  describe "game state"
  [ describe "when the page loads"
    [ test "it calls the view adapter with a game state of InProgress" <|
      \() ->
        Elmer.given testModel (Core.view <| Spy.callable "view-spy") (testUpdate [ Orange ])
          |> Spy.use [ viewSpy ]
          |> Elmer.init (\_ -> testInit [[Blue]])
          |> Markup.render
          |> Spy.expect "view-spy" (
            wasCalledWith [ typedArg <| InProgress maxGuesses, anyArg ]
          )
    ]
  , describe "when the guess is wrong"
    [ test "it decreases the number of remaining guesses by one" <|
      \() ->
        Elmer.given testModel (Core.view <| Spy.callable "view-spy") (testUpdate [ Orange ])
          |> Spy.use [ viewSpy ]
          |> Elmer.init (\_ -> testInit [[Blue], [Green], [Red]])
          |> Markup.target "#submit-code"
          |> Event.click
          |> Event.click
          |> Event.click
          |> Spy.expect "view-spy" (
            wasCalledWith [ typedArg <| InProgress (maxGuesses - 3), anyArg ]
          )
    ]
  , describe "when the guess is correct" <|
    let
      state =
        Elmer.given testModel (Core.view <| Spy.callable "view-spy") (testUpdateWithHighScores [ Orange ])
          |> Spy.use [ viewSpy, scoreStoreSpy [ 190, 276, 310 ] ]
          |> Elmer.init (\_ -> testInit [[Orange]])
          |> Markup.target "#submit-code"
          |> Event.click
    in
    [ test "it returns Correct as the feedback" <|
      \() ->
        state
          |> Elmer.expectModel (\model ->
              Core.viewModel model
                |> .feedback
                |> Expect.equal (Just Correct)
            )
    , test "it requests the high scores" <|
      \() ->
        state
          |> Spy.expect "update-score-store-spy" (
            wasCalledWith [ typedArg Nothing ]
          )
    ]
  , describe "when the max number of incorrect answers has been given"
    [ test "it calls the view adapter with a game state of Lost and the code" <|
      \() ->
        let
          gameConfig = { maxGuesses = 3 }
        in
          Elmer.given testModel (Core.view <| Spy.callable "view-spy") (testUpdate [ Orange ])
            |> Spy.use [ viewSpy ]
            |> Elmer.init (\_ -> Core.initGame gameConfig <| FakeUI.defaultModel [[Blue], [Red], [Green]])
            |> Markup.target "#submit-code"
            |> Event.click
            |> Event.click
            |> Event.click
            |> Spy.expect "view-spy" (
              wasCalledWith [ typedArg <| Lost [ Orange ], anyArg ]
            )
    ]
  ]


scoreTests : Test
scoreTests =
  describe "when the guess is correct"
  [ describe "when one correct guess is made after a few seconds" <|
    let
      state =
        Elmer.given testModel (Core.view <| Spy.callable "view-spy") (testUpdateWithHighScores [ Orange ])
          |> Spy.use [ viewSpy, timeSpy, scoreStoreSpy [ 190, 276, 310 ] ]
          |> Elmer.init (\_ -> testInit [[Orange]])
          |> Subscription.with (\_ -> Core.subscriptions)
          |> Subscription.send "time-sub" 1
          |> Subscription.send "time-sub" 1
          |> Subscription.send "time-sub" 1
          |> Subscription.send "time-sub" 1
          |> Markup.target "#submit-code"
          |> Event.click
    in
    [ test "the score is 50 plus the number of seconds" <|
      \() ->
        state
          |> Spy.expect "view-spy" (
            wasCalledWith [ typedArg <| Won 54, anyArg ]
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
        Elmer.given testModel (Core.view <| Spy.callable "view-spy") (testUpdateWithHighScores [ Orange ])
          |> Spy.use [ viewSpy, timeSpy, scoreStoreSpy [ 190, 276, 310 ] ]
          |> Elmer.init (\_ -> testInit [[Red], [Green], [Orange]])
          |> Subscription.with (\_ -> Core.subscriptions)
          |> elapseSeconds 4
          |> Markup.target "#submit-code"
          |> Event.click
          |> elapseSeconds 3
          |> Markup.target "#submit-code"
          |> Event.click
          |> elapseSeconds 6
          |> Markup.target "#submit-code"
          |> Event.click
    in
    [ test "the score is 50 * number of guesses plus number of seconds" <|
      \() ->
        state
          |> Spy.expect "view-spy" (
            wasCalledWith [ typedArg <| Won 163, anyArg ]
          )
    , test "it saves the score" <|
      \() ->
        state
          |> Spy.expect "update-score-store-spy" (
            wasCalledWith [ typedArg <| Just 163 ]
          )
    ]
  ]


clueTests : Test
clueTests =
  describe "clues"
  [ describe "when no colors are correct"
    [ test "it returns a clue with 0 colors correct" <|
      \() ->
        expectFeedback [ Blue ] [ Green ] <|
          wrongFeedback 0 0
    ]
  , describe "when only one color is correct"
    [ test "it returns a clue with 1 color correct" <|
      \() ->
        expectFeedback [ Blue, Red ] [ Yellow, Blue ] <|
          wrongFeedback 1 0
    ]
  , describe "when there are matching identical colors in the guess"
    [ test "it should only match the number in the code" <|
      \() ->
        expectFeedback [ Blue, Blue, Yellow, Blue, Orange ] [ Green, Red, Blue, Red, Blue ] <|
          wrongFeedback 2 0
    ]
  , describe "when more than one color is correct"
    [ test "it returns a clue with the right number of correct colors" <|
      \() ->
        expectFeedback [ Blue, Yellow, Red ] [ Yellow, Blue, Green ] <|
          wrongFeedback 2 0
    ]
  , describe "when one color is in the right position"
    [ test "it returns a clue with one in the right position" <|
      \() ->
        expectFeedback [ Blue, Yellow, Yellow ] [ Green, Yellow, Blue ] <|
          wrongFeedback 2 1
    ]
  , describe "when more than one color is in the right position"
    [ test "it returns a clue with the number in the right position" <|
      \() ->
        expectFeedback [ Blue, Yellow, Yellow ] [ Green, Yellow, Yellow ] <|
          wrongFeedback 2 2
    ]
  ]


elapseSeconds : Int -> TestState model msg -> TestState model msg
elapseSeconds seconds testState =
  (\state -> Subscription.send "time-sub" 1 state)
    |> List.repeat seconds
    |> TestHelpers.foldStates testState


wrongFeedback : Int -> Int -> GuessFeedback
wrongFeedback colorsCorrect positionsCorrect =
  Clue.with colorsCorrect positionsCorrect
    |> Wrong


expectFeedback : Code -> Code -> GuessFeedback -> Expectation
expectFeedback code guess expectedFeedback =
  Elmer.given testModel testView (testUpdate code)
    |> Elmer.init (\_ -> testInit [guess])
    |> Markup.target "#submit-code"
    |> Event.click
    |> Elmer.expectModel (\model ->
        Core.viewModel model
          |> .feedback
          |> Expect.equal (Just expectedFeedback)
      )


timeSpy : Spy
timeSpy =
  Spy.create "time-spy" (\_ -> Time.every)
    |> andCallFake (\_ tagger ->
      Subscription.fake "time-sub" tagger
    )

maxGuesses = 18

scoreStoreSpy : List Score -> Spy
scoreStoreSpy scores =
  Core.highScoresTagger 5 FakeUI.UpdateHighScores
    |> CoreHelpers.updateScoreStoreSpy scores


viewSpy : Spy
viewSpy =
  Spy.create "view-spy" (\_ -> FakeUI.view)

testModel =
  FakeUI.defaultModel []
    |> Core.defaultModel testConfig

testConfig =
  { maxGuesses = maxGuesses
  }

testView =
  Core.view FakeUI.view

testUpdateWithHighScores code =
  let
    adapters = CoreHelpers.coreAdapters code
  in
    { adapters | updateScoreStore = Spy.callable "update-score-store-spy" }
      |> Core.update

testUpdate =
  CoreHelpers.testUpdate

testInit guesses =
  FakeUI.defaultModel guesses
    |> Core.initGame testConfig
