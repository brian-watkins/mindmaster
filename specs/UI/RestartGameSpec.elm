module UI.RestartGameSpec exposing (main)

import Spec exposing (..)
import Spec.Subject as Subject
import Spec.Observer as Observer
import Spec.Markup as Markup
import Spec.Markup.Selector exposing (..)
import Spec.Markup.Event as Event
import Spec.Claim as Claim
import Spec.Command as Command
import Spec.Witness as Witness
import Spec.Extra exposing (..)
import UI.Types exposing (..)
import Game.Types exposing (..)
import Game.Types exposing (GameState(..), Color(..))
import UI
import UI.Helpers
import Runner


restartSpec : Spec Model Msg
restartSpec =
  Spec.describe "restart game"
  [ scenario "after winning" (
      given (
        UI.Helpers.testSubject <| Won 472
      )
      |> when "the new game is button is clicked"
        [ Markup.target << by [ id "new-game" ]
        , Event.click
        ]
      |> UI.Helpers.itRestartsTheGame
    )
  , scenario "after losing" (
      given (
        UI.Helpers.testSubject <| Lost [ Red, Yellow, Yellow ]
      )
      |> when "the new game is button is clicked"
        [ Markup.target << by [ id "new-game" ]
        , Event.click
        ]
      |> UI.Helpers.itRestartsTheGame
    )
  ]


main =
  Runner.program
    [ restartSpec
    ]