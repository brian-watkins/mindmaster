module Core.StartGameUseCaseTests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Elmer
import Elmer.Html as Markup
import Elmer.Html.Event as Event
import Elmer.Spy as Spy exposing (Spy)
import Elmer.Spy.Matchers exposing (wasCalledWith, typedArg, anyArg)
import Bus
import Game.Types exposing (..)
import Core.Fakes.FakeUI as FakeUI
import Core.Fakes.FakeCodeGenerator as FakeCodeGenerator
import Core.TestHelpers as CoreHelpers

startGameTests : Test
startGameTests =
  describe "when the core is initialized" <|
  let
    state =
      Elmer.given (CoreHelpers.testModelWithMax 8) (Bus.view <| Spy.callable "view-spy") (testUpdate [ Blue ])
        |> Spy.use [ CoreHelpers.viewSpy, scoreStoreSpy ]
        |> Elmer.init (\_ -> testInitWithMax 8 [[Orange]] [Blue])
  in
  [ test "it restarts the game" <|
    \() ->
      state
        |> Markup.target "#submit-code"
        |> Event.click
        |> Spy.use [ CoreHelpers.viewSpy ] -- reset spy history
        |> Markup.target "#restart-game"
        |> Event.click
        |> Spy.expect "view-spy" (
          wasCalledWith [ typedArg <| InProgress 8, anyArg ]
        )
  , test "it resets the number of guesses to zero" <|
    \() ->
      state
        |> Markup.target "#submit-code"
        |> Event.click
        |> Event.click
        |> Event.click
        |> Spy.use [ CoreHelpers.viewSpy ] -- reset spy history
        |> Markup.target "#restart-game"
        |> Event.click
        |> Markup.target "#submit-code"
        |> Event.click
        |> Spy.expect "view-spy" (
          wasCalledWith [ typedArg <| InProgress 7, anyArg ]
        )
  , test "it requests the high scores" <|
    \() ->
      state
        |> Spy.expect "update-score-store-spy" (
          wasCalledWith [ typedArg Nothing ]
        )
  ]


scoreStoreSpy : Spy
scoreStoreSpy =
  CoreHelpers.updateScoreStoreSpy


testUpdate code =
  Bus.update (adapters code)


adapters code =
  let
    adapters = CoreHelpers.coreAdapters code
  in
    { adapters | updateScoreStore = Spy.callable "update-score-store-spy" }


testInitWithMax maxGuesses guesses code =
  FakeUI.defaultModel guesses
    |> Bus.init (CoreHelpers.testConfig maxGuesses) (adapters code)
