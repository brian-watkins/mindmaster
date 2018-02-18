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
import Core.TestHelpers as CoreHelpers

startGameTests : Test
startGameTests =
  describe "when the core is initialized" <|
  let
    state =
      Elmer.given testModel (Core.view <| Spy.callable "view-spy") (testUpdate [ Blue ])
        |> Spy.use [ viewSpy, scoreStoreSpy [ 190, 276, 310 ] ]
        |> Elmer.init (\_ -> testInit [[Orange]])
  in
  [ test "it restarts the game" <|
    \() ->
      state
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
      state
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
  , test "it requests the high scores" <|
    \() ->
      state
        |> Spy.expect "update-score-store-spy" (
          wasCalledWith [ typedArg Nothing ]
        )
  ]

maxGuesses = 18

viewSpy : Spy
viewSpy =
  Spy.create "view-spy" (\_ -> FakeUI.view)

scoreStoreSpy : List Score -> Spy
scoreStoreSpy scores =
  Core.highScoresTagger 5 FakeUI.UpdateHighScores
    |> CoreHelpers.updateScoreStoreSpy scores


testModel =
  FakeUI.defaultModel []
    |> Core.defaultModel testConfig

testView =
  Core.view FakeUI.view


testUpdate code =
  let
    adapters = CoreHelpers.coreAdapters code
  in
    { adapters | updateScoreStore = Spy.callable "update-score-store-spy" }
      |> Core.update


testInit guesses =
  FakeUI.defaultModel guesses
    |> Core.initGame testConfig

testConfig =
  { maxGuesses = maxGuesses
  }
