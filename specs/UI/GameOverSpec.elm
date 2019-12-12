module UI.GameOverSpec exposing (main)

import Spec exposing (..)
import Spec.Setup as Setup
import Spec.Observer as Observer
import Spec.Markup as Markup
import Spec.Markup.Selector exposing (..)
import Spec.Witness as Witness
import Spec.Claim as Claim
import Spec.Command as Command
import Spec.Extra exposing (..)
import UI.Types exposing (..)
import Game.Types exposing (..)
import Game.Types exposing (GameState(..), Color(..))
import UI
import UI.Helpers
import Runner


gameOverSpec : Spec Model Msg
gameOverSpec =
  Spec.describe "the game is over"
  [ scenario "the game is won" (
      given (
        UI.Helpers.testSubject <| Won 350
      )
      |> observeThat
        [ it "shows that you won" (
            Markup.observeElement
              |> Markup.query << by [ id "game-over-message" ]
              |> expect (Markup.hasText "You won!")
          )
        , it "shows your score" (
            Markup.observeElement
              |> Markup.query << by [ id "final-score" ]
              |> expect (Markup.hasText "Final Score: 350")
          )
        , itNoLongerShowsGuessInput
        ]
    )
  , scenario "the game is lost" (
      given (
        UI.Helpers.testSubject <| Lost [ Orange, Blue, Yellow ]
      )
      |> observeThat
        [ it "says you lost" (
            Markup.observeElement
              |> Markup.query << by [ id "game-over-message" ]
              |> expect (Markup.hasText "You lost!")
          )
        , it "shows the correct code" (
            Markup.observeElements
              |> Markup.query << by [ attributeName "data-code-element" ]
              |> expect (Claim.isListWhere
                [ Markup.hasAttribute ("class", "orange")
                , Markup.hasAttribute ("class", "blue")
                , Markup.hasAttribute ("class", "yellow")
                ]
              )
          )
        , itNoLongerShowsGuessInput
        ]
    )
  ]


itNoLongerShowsGuessInput =
  it "no longer shows the guess input" (
    Markup.observe
      |> Markup.query << by [ id "guess-input" ]
      |> expect Claim.isNothing
  )


main =
  Runner.program
    [ gameOverSpec
    ]