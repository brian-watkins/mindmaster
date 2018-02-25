module UI.HighScoreTests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Elmer
import Elmer.Html as Markup
import Elmer.Html.Matchers exposing (element, hasText)
import Elmer.Platform.Command as Command
import UI
import UI.Types exposing (..)
import Game.Types exposing (Color(..), GameState(..))
import UI.TestHelpers as UIHelpers


noScoresTests : Test
noScoresTests =
  describe "when there are no high scores"
  [ test "it says there are no high scores" <|
    \() ->
      Elmer.given testModel (UI.view <| InProgress 10) testUpdate
        |> Command.send (\() -> Command.fake <| UI.highScoresTagger [])
        |> Markup.target "#high-scores"
        |> Markup.expect (element <|
          hasText "No scores recorded."
        )
  ]


testUpdate : Msg -> Model -> (Model, Cmd msg)
testUpdate =
  UIHelpers.viewDependencies
    |> UIHelpers.testUpdate


testModel : Model
testModel =
  UI.defaultModel { codeLength = 3, colors = testColors }


testColors : List Color
testColors =
  [ Red, Orange, Yellow, Blue, Green ]
