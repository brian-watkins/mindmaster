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
        Elmer.given testModel testView (testUpdate yellowCode)
          |> Markup.target "#submit-code"
          |> Event.click
          |> Elmer.expectModel (\model ->
              Core.viewModel model
                |> .feedback
                |> Expect.equal (Just <| wrongFeedback 0)
            )
    ]
  , describe "when there is a code"
    [ describe "when the guess is correct"
      [ test "it returns Correct as the feedback" <|
        \() ->
          Correct
            |> expectFeedback orangeCode orangeCode
      ]
    ]
  ]


colorClueTests : Test
colorClueTests =
  describe "color clues"
  [ describe "when no colors are correct"
    [ test "it returns a clue with 0 colors correct" <|
      \() ->
        wrongFeedback 0
          |> expectFeedback yellowCode greenCode
    ]
  , describe "when one color is correct"
    [ test "it returns a clue with 1 color correct" <|
      \() ->
        wrongFeedback 1
          |> expectFeedback orangeCode greenCode
    ]
  , describe "when more than one color is correct"
    [ test "it returns a clue with the right number of correct colors" <|
      \() ->
        wrongFeedback 3
          |> expectFeedback orangeCode yellowCode
    ]
  ]


wrongFeedback : Int -> GuessFeedback
wrongFeedback colorsCorrect =
  Clue.withColorsCorrect colorsCorrect
    |> Wrong

expectFeedback : List Color -> List Color -> GuessFeedback -> Expectation
expectFeedback code guess expectedFeedback =
  Elmer.given testModel testView (testUpdate code)
    |> Elmer.init (\_ -> testInit guess)
    |> Markup.target "#submit-code"
    |> Event.click
    |> Elmer.expectModel (\model ->
        Core.viewModel model
          |> .feedback
          |> Expect.equal (Just expectedFeedback)
      )

yellowCode : List Color
yellowCode =
  [ Yellow, Yellow, Blue, Blue ]

orangeCode : List Color
orangeCode =
  [ Yellow, Yellow, Blue, Green ]

greenCode : List Color
greenCode =
  [ Green, Green, Green, Green ]

testModel =
  Core.defaultModel FakeUI.defaultModel

testView =
  Core.view FakeUI.view

testUpdate code =
  FakeUI.update code
    |> Core.update

testInit code =
  Core.initGame (FakeCodeGenerator.with code) FakeUI.defaultModel
