module Game.GameStateSpec exposing (main)

import Spec exposing (..)
import Spec.Setup as Setup
import Spec.Observer as Observer
import Spec.Report as Report
import Spec.Claim as Claim
import Spec.Extra exposing (equals)
import Spec.Time as Time
import Game.UseCases as UseCases
import Game.Types exposing (..)
import Game.Helpers exposing (Msg(..), Model)
import Runner


gameStateSpec : Spec Model Msg
gameStateSpec =
  Spec.describe "game states"
  [ scenario "when the page loads" (
      given (
        Game.Helpers.testSubject 7 []
      )
      |> it "reports the game state as InProgress with the max remaining guesses" (
        Game.Helpers.expectGameState <| InProgress 7
      )
    )
  , scenario "an incorrect guess" (
      given (
        Game.Helpers.testSubject 17 [ Orange ]
      )
      |> when "an incorrect guess is made"
        [ Game.Helpers.evaluateGuess [ Blue ]
        , Game.Helpers.evaluateGuess [ Red ]
        , Game.Helpers.evaluateGuess [ Green ]
        ]
      |> it "decreases the number of guesses remaining by one" (
        Game.Helpers.expectGameState <| InProgress 14
      )
    )
  , scenario "a correct guess" (
      given (
        Game.Helpers.testSubject 17 [ Orange ]
      )
      |> when "the guess is correct"
        [ Game.Helpers.evaluateGuess [ Orange ]
        ]
      |> it "reports the game state as Won" (
        Game.Helpers.expectGameModel (\model ->
          case UseCases.gameState model of
            Won _ ->
              Claim.Accept
            _ ->
              Claim.Reject <| Report.note "Game state should be Won!"
        )
      )
    )
  , scenario "max number of guesses reached" (
      given (
        Game.Helpers.testSubject 2 [ Orange ]
      )
      |> when "the guesses have been exhausted"
        [ Game.Helpers.evaluateGuess [ Red ]
        , Game.Helpers.evaluateGuess [ Blue ]
        ]
      |> it "reports the game state as Lost with the code" (
        Game.Helpers.expectGameState <| Lost [ Orange ]
      )
    )
  ]


scoreSpec : Spec Model Msg
scoreSpec =
  Spec.describe "score"
  [ scenario "one correct guess after a few seconds" (
      given (
        Game.Helpers.testSubject 10 [ Red, Blue ]
          |> Setup.withSubscriptions Game.Helpers.testSubscriptions
      )
      |> whenTimeElapses 8000
      |> when "the correct guess is submitted"
        [ Game.Helpers.evaluateGuess [ Red, Blue ]
        ]
      |> observeThat
        [ it "shows the score to be 50 plus the number of seconds" (
            Game.Helpers.expectGameState <| Won (50 + 8)
          )
        , it "records the score" (
            Game.Helpers.expectStoredScore (50 + 8)
          )
        ]
    )
  , scenario "several incorrect guesses before the correct one" (
      given (
        Game.Helpers.testSubject 10 [ Red, Blue ]
          |> Setup.withSubscriptions Game.Helpers.testSubscriptions
      )
      |> whenTimeElapses 4000
      |> when "an incorrect guess is submitted"
        [ Game.Helpers.evaluateGuess [ Green, Green ]
        ]
      |> whenTimeElapses 7000
      |> when "another incorrect guess is submitted"
        [ Game.Helpers.evaluateGuess [ Blue, Blue ]
        ]
      |> whenTimeElapses 3000
      |> when "the correct guess is submitted"
        [ Game.Helpers.evaluateGuess [ Red, Blue ]
        ]
      |> observeThat
        [ it "shows the score to be 50 * number guesses plus the number of seconds" (
            Game.Helpers.expectGameState <| Won (50 * 3 + 14)
          )
        , it "records the score" (
            Game.Helpers.expectStoredScore (50 * 3 + 14)
          )
        ]
    )
  ]


whenTimeElapses millis =
  when "some time elapses"
    [ Time.tick millis
    ]


main =
  Runner.program
    [ gameStateSpec
    , scoreSpec
    ]