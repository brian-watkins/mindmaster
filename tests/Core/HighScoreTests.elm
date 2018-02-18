module Core.HighScoreTests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Elmer
import Elmer.Spy as Spy exposing (Spy)
import Core.TestHelpers as CoreHelpers
import Core.Types exposing (Color(..), Score)
import Core
import Core.Fakes.FakeUI as FakeUI


orderTests : Test
orderTests =
  describe "when the scores are returned" <|
  let
    state =
      Elmer.given testModel testView testUpdate
        |> Spy.use [ scoreStoreSpy [ 210, 14, 381, 276, 310 ] ]
        |> Elmer.init (\_ -> testInit)
  in
  [ test "it orders the scores from lowest to highest" <|
    \() ->
      state
        |> Elmer.expectModel (\model ->
          Core.viewModel model
            |> .highScores
            |> Expect.equal [ 14, 210, 276, 310, 381 ]
        )
  ]

topTests : Test
topTests =
  describe "when more than the top scores are returned" <|
  let
    state =
      Elmer.given testModel testView testUpdate
        |> Spy.use [ scoreStoreSpy [ 210, 14, 381, 276, 310, 12, 88, 113 ] ]
        |> Elmer.init (\_ -> testInit)
  in
  [ test "it returns only the top scores" <|
    \() ->
      state
        |> Elmer.expectModel (\model ->
          Core.viewModel model
            |> .highScores
            |> Expect.equal [ 12, 14, 88, 113, 210 ]
        )
  ]


scoreStoreSpy : List Score -> Spy
scoreStoreSpy scores =
  Core.highScoresTagger 5 FakeUI.UpdateHighScores
    |> CoreHelpers.updateScoreStoreSpy scores


testView =
  Core.view <| FakeUI.view

testUpdate =
  let
    adapters = CoreHelpers.coreAdapters [ Blue ]
  in
    { adapters | updateScoreStore = Spy.callable "update-score-store-spy" }
      |> Core.update

testInit =
  FakeUI.defaultModel []
    |> Core.initGame testConfig

testModel =
  FakeUI.defaultModel []
    |> Core.defaultModel testConfig

testConfig =
  { maxGuesses = 4 }
