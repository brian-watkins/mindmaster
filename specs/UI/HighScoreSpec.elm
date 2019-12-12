module UI.HighScoreSpec exposing (main)

import Spec exposing (..)
import Spec.Setup as Setup
import Spec.Observer as Observer
import Spec.Markup as Markup
import Spec.Markup.Selector exposing (..)
import Spec.Claim as Claim
import Spec.Command as Command
import Spec.Extra exposing (..)
import UI.Types exposing (..)
import Game.Types exposing (..)
import Game.Types exposing (GameState(..), Color(..))
import UI
import UI.Helpers
import Runner


highScoreSpec : Spec Model Msg
highScoreSpec =
  Spec.describe "high scores"
  [ scenario "no high scores" (
      given (
        testSubject
      )
      |> when "the high scores are updated"
        [ Command.send <| Command.fake <| UI.highScoresTagger []
        ]
      |> it "indicates that there are no high scores" (
        Markup.observeElement
          |> Markup.query << by [ id "high-scores" ]
          |> expect (Markup.hasText "No scores recorded.")
      )
    )
  , scenario "some high scores" (
      given (
        testSubject
      )
      |> when "the high scores are updated"
        [ Command.send <| Command.fake <| UI.highScoresTagger [ 180, 190, 210 ]
        ]
      |> it "shows the high scores" (
        Markup.observeElement
          |> Markup.query << by [ id "high-scores" ]
          |> expect (Claim.satisfying
            [ Markup.hasText "180"
            , Markup.hasText "190"
            , Markup.hasText "210"
            ]
          )
      )
    )
  ]


testSubject =
  UI.Helpers.testSubject <| InProgress 5


main =
  Runner.program
    [ highScoreSpec
    ]