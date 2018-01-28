module Core.PlayGuessUseCaseTests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Elmer
import Elmer.Html as Markup
import Elmer.Html.Event as Event
import Elmer.Html.Matchers exposing (element, hasText)
import Elmer.Spy as Spy exposing (Spy)
import Elmer.Spy.Matchers exposing (wasCalledWith, stringArg)
import Elmer.Platform.Command as Command
import Core
import Core.Clue as Clue
import Core.Types exposing (GuessFeedback(..), Color(..))
import Core.Fakes.FakeUI as FakeUI
import Core.Fakes.FakeCodeGenerator as FakeCodeGenerator


playGuessTests : Test
playGuessTests =
  describe "when a guess is played"
  [ describe "when there is no code"
    [ test "it returns Wrong" <|
      \() ->
        Elmer.given testModel testView (testUpdate [ Yellow, Blue ])
          |> Markup.target "#submit-code"
          |> Event.click
          |> Elmer.expectModel (\model ->
              Core.viewModel model
                |> .feedback
                |> Expect.equal (Just <| wrongFeedback 0 0)
            )
    ]
  , describe "when there is a code"
    [ describe "when the guess is correct"
      [ test "it returns Correct as the feedback" <|
        \() ->
          Correct
            |> expectFeedback [ Orange ] [ Orange ]
      ]
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


wrongFeedback : Int -> Int -> GuessFeedback
wrongFeedback colorsCorrect positionsCorrect =
  Clue.with colorsCorrect positionsCorrect
    |> Wrong

expectFeedback : List Color -> List Color -> GuessFeedback -> Expectation
expectFeedback code guess expectedFeedback =
  Elmer.given testModel testView (testUpdate guess)
    |> Elmer.init (\_ -> testInit code)
    |> Markup.target "#submit-code"
    |> Event.click
    |> Elmer.expectModel (\model ->
        Core.viewModel model
          |> .feedback
          |> Expect.equal (Just expectedFeedback)
      )


testModel =
  Core.defaultModel FakeUI.defaultModel

testView =
  Core.view FakeUI.view

testUpdate code =
  FakeUI.update code
    |> Core.update

testInit code =
  Core.initGame (FakeCodeGenerator.with code) FakeUI.defaultModel
