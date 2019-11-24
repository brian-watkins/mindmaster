module Game.StartGameSpec exposing (main)

import Spec exposing (Spec)
import Spec.Scenario exposing (..)
import Spec.Subject as Subject
import Spec.Observer as Observer
import Spec.Observation.Report as Report
import Spec.Claim as Claim
import Spec.Extra exposing (equals)
import Spec.Time as Time
import Game.UseCases as UseCases
import Game.Types exposing (..)
import Game.Helpers exposing (Msg(..), Model)
import Runner

startGameSpec : Spec Model Msg
startGameSpec =
  Spec.describe "starting a game"
  [ scenario "after the current game is finished" (
      givenANewGameIsStartedWithCode [ Blue, Green, Blue ]
        |> observeThat
          [ it "resets the game state" (
              Game.Helpers.expectGameState <| InProgress 3
            )
          ]
    )
  , scenario "the new game is played" (
      givenANewGameIsStartedWithCode [ Blue, Green, Blue ]
        |> when "an incorrect guess is evaluated"
          [ Game.Helpers.evaluateGuess [ Blue, Blue, Blue ]
          ]
        |> it "decreases the number of remaining guesses by one" (
          Game.Helpers.expectGameState <| InProgress 2
        )
    )
  , scenario "the new game is won" (
      givenANewGameIsStartedWithCode [ Blue, Green, Blue ]
        |> when "a correct guess is evaluated"
          [ Game.Helpers.evaluateGuess [ Blue, Green, Blue ]
          ]
        |> it "uses the new code to judge the guess" (
          Game.Helpers.expectGameModel (\model ->
            case UseCases.gameState model of
              Won _ ->
                Claim.Accept
              _ ->
                Claim.Reject <| Report.note "Expected game to be won!"
          )
        )
    )
  ]


givenANewGameIsStartedWithCode code =
  given (
    Game.Helpers.testSubject 3 [ Orange, Red, Blue ]
  )
  |> when "the game is lost"
    [ Game.Helpers.evaluateGuess [ Red, Red, Red ]
    , Game.Helpers.evaluateGuess [ Red, Red, Blue ]
    , Game.Helpers.evaluateGuess [ Red, Red, Yellow ]
    ]
  |> when "a new game is started"
    [ Game.Helpers.startNewGame code
    ]


main =
  Runner.program
    [ startGameSpec
    ]