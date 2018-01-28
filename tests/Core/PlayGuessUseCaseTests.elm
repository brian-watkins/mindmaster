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
import Core.Types exposing (GuessFeedback(..), Color(..))
import Core.Fakes.FakeUI as FakeUI
import Core.Fakes.FakeCodeGenerator as FakeCodeGenerator


yellowCode : List Color
yellowCode =
  [ Yellow, Yellow, Blue, Blue ]

orangeCode : List Color
orangeCode =
  [ Orange, Yellow, Blue, Green ]

testModel =
  Core.defaultModel FakeUI.defaultModel

testView =
  Core.view FakeUI.view

testUpdate code =
  FakeUI.update code
    |> Core.update

testInit code =
  Core.initGame (FakeCodeGenerator.with code) FakeUI.defaultModel

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
                |> Expect.equal (Just Wrong)
            )
    ]
  , describe "when there is a code"
    [ describe "when the guess is wrong"
      [ test "it returns Wrong as the feedback" <|
        \() ->
          Elmer.given testModel testView (testUpdate yellowCode)
            |> Elmer.init (\_ -> testInit orangeCode)
            |> Markup.target "#submit-code"
            |> Event.click
            |> Elmer.expectModel (\model ->
                Core.viewModel model
                  |> .feedback
                  |> Expect.equal (Just Wrong)
              )
      ]
    , describe "when the guess is correct"
      [ test "it returns Correct as the feedback" <|
        \() ->
          Elmer.given testModel testView (testUpdate orangeCode)
            |> Elmer.init (\_ -> testInit orangeCode)
            |> Markup.target "#submit-code"
            |> Event.click
            |> Elmer.expectModel (\model ->
                Core.viewModel model
                  |> .feedback
                  |> Expect.equal (Just Correct)
              )
      ]
    ]
  ]
