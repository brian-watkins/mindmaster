module UI.HighScoreSpec exposing (main)

import Spec exposing (..)
import Spec.Setup as Setup
import Spec.Observer as Observer
import Spec.Markup as Markup
import Spec.Markup.Selector exposing (..)
import Spec.Claim as Claim
import Spec.Command as Command
import Spec.Extra exposing (..)
import UI.Types as UITypes
import Game.Types exposing (..)
import Game.Types exposing (GameState(..), Color(..))
import UI
import UI.Helpers
import Runner


highScoreSpec : Spec UITypes.Model UITypes.Msg
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
          |> expectElement (hasText "No scores recorded.")
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
          |> expectElement (Claim.satisfying
            [ hasText "180"
            , hasText "190"
            , hasText "210"
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