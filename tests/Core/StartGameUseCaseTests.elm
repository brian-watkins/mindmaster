module Core.StartGameUseCaseTests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Elmer
import Elmer.Html as Markup
import Elmer.Html.Event as Event
import Elmer.Spy as Spy exposing (Spy)
import Elmer.Spy.Matchers exposing (wasCalledWith, typedArg, anyArg)
import Core
import Core.Types exposing (..)
import Core.Fakes.FakeUI as FakeUI
import Core.Fakes.FakeCodeGenerator as FakeCodeGenerator


startGameTests : Test
startGameTests =
  describe "when the start game command is sent"
  [ test "it restarts the game" <|
    \() ->
      Elmer.given testModel (Core.view <| Spy.callable "view-spy") (testUpdate [ Blue ] [ Orange ])
        |> Spy.use [ viewSpy ]
        |> Elmer.init (\_ -> testInit)
        |> Markup.target "#submit-code"
        |> Event.click
        |> Spy.use [ viewSpy ] -- reset spy history
        |> Markup.target "#restart-game"
        |> Event.click
        |> Spy.expect "view-spy" (
          wasCalledWith [ typedArg <| InProgress maxGuesses, anyArg ]
        )
  , test "it resets the number of guesses to zero" <|
    \() ->
      Elmer.given testModel (Core.view <| Spy.callable "view-spy") (testUpdate [ Blue ] [ Orange ])
        |> Spy.use [ viewSpy ]
        |> Elmer.init (\_ -> testInit)
        |> Markup.target "#submit-code"
        |> Event.click
        |> Event.click
        |> Event.click
        |> Spy.use [ viewSpy ] -- reset spy history
        |> Markup.target "#restart-game"
        |> Event.click
        |> Markup.target "#submit-code"
        |> Event.click
        |> Spy.expect "view-spy" (
          wasCalledWith [ typedArg <| InProgress (maxGuesses - 1), anyArg ]
        )
  ]

maxGuesses = 18

viewSpy : Spy
viewSpy =
  Spy.create "view-spy" (\_ -> FakeUI.view)

testModel =
  Core.defaultModel testConfig FakeUI.defaultModel

testView =
  Core.view FakeUI.view

testUpdate code guess =
  testAdapters code guess
    |> Core.update

testInit =
  Core.initGame testConfig FakeUI.defaultModel

testConfig =
  { maxGuesses = maxGuesses
  }

testAdapters code guess =
  { viewUpdate = FakeUI.update guess
  , codeGenerator = FakeCodeGenerator.with code
  }