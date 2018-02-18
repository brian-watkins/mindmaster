module UI.RestartGameTests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Elmer exposing (TestState, hasLength)
import Elmer.Html as Markup
import Elmer.Html.Matchers exposing (elements, elementExists)
import Elmer.Html.Event as Event
import Elmer.Platform.Command as Command
import UI
import UI.Types exposing (..)
import UI.TestHelpers as UIHelpers
import Core.Types exposing (GameState(..), Color(..))


restartAfterWinTests : Test
restartAfterWinTests =
  describe "start a new game after winning" <|
  let
    state =
      Elmer.given testModel (UI.view <| Won 300) testUpdate
  in
  [ restartTests state
  ]


restartAfterLossTests : Test
restartAfterLossTests =
  describe "start a new game after losing" <|
  let
    state =
      Elmer.given testModel (UI.view <| Lost [ Red ]) testUpdate
  in
  [ restartTests state
  ]


restartTests : TestState model msg -> Test
restartTests testState =
  describe "when the new game button is clicked" <|
  let
    newGameState =
      testState
        |> Markup.target "#new-game"
        |> Event.click
  in
  [ test "it sends the command to start the game" <|
    \() ->
      newGameState
        |> Command.expectDummy "restart-game"
  ]


restartGameCommand : Cmd msg
restartGameCommand =
  Command.dummy "restart-game"


testUpdate : Msg -> Model -> (Model, Cmd msg)
testUpdate =
  let
    dependencies = UIHelpers.viewDependencies
  in
    UIHelpers.testUpdate <|
      { dependencies | restartGameCommand = restartGameCommand }


testModel : Model
testModel =
  UI.defaultModel { codeLength = 3, colors = testColors }


testColors : List Color
testColors =
  [ Red, Orange, Yellow, Blue, Green ]
