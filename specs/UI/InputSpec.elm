module UI.InputSpec exposing (main)

import Spec exposing (..)
import Spec.Setup as Setup
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


selectElementSpec : Spec Model Msg
selectElementSpec =
  Spec.describe "selecting elements for a guess"
  [ scenario "red is selected" (
      given (
        testSubject
      )
      |> whenSelectGuess [ Just "red" ]
      |> it "shows red as selected" (
        expectGuess [ "red", "empty", "empty", "empty", "empty" ]
      )
    )
  , scenario "red is selected" (
      given (
        testSubject
      )
      |> whenSelectGuess [ Just "red", Just "orange" ]
      |> it "shows red as selected" (
        expectGuess [ "red", "orange", "empty", "empty", "empty" ]
      )
    )
  , scenario "yellow is selected" (
      given (
        testSubject
      )
      |> whenSelectGuess [ Nothing, Nothing, Just "yellow" ]
      |> it "shows red as selected" (
        expectGuess [ "empty", "empty", "yellow", "empty", "empty" ]
      )
    )
  , scenario "green is selected" (
      given (
        testSubject
      )
      |> whenSelectGuess [ Nothing, Just "orange", Just "green" ]
      |> it "shows green as selected" (
        expectGuess [ "empty", "orange", "green", "empty", "empty" ]
      )
    )
  , scenario "blue is selected" (
      given (
        testSubject
      )
      |> whenSelectGuess [ Just "red", Just "orange", Just "yellow", Just "green", Just "blue" ]
      |> it "shows red as selected" (
        expectGuess [ "red", "orange", "yellow", "green", "blue" ]
      )
    )
  ]


expectGuess cssCodes =
  Markup.observeElements
    |> Markup.query
        << by [ attributeName "data-guess-input-element" ]
    |> expect (Claim.isListWhere <|
      List.map (\c -> Markup.hasAttribute ("class", c)) cssCodes  
    )


whenSelectGuess colors =
  when ("" ++ (String.join ", " <| List.map (Maybe.withDefault "[Nothing]") colors) ++ " is selected") <|
    List.concat <| List.indexedMap selectGuessElement colors


selectGuessElement position maybeClass =
  case maybeClass of
    Just class ->
      [ Markup.target
          << descendantsOf [ attribute ("data-guess-input", String.fromInt position) ]
          << by [ attribute ("class", class) ]
      , Event.click
      ]
    Nothing ->
      []


testSubject =
  Setup.initWithModel (UI.Helpers.testModel 5)
    |> Witness.forUpdate (UI.Helpers.testUpdate (\_ -> Wrong { colors = 0, positions = 0 }))
    |> Setup.withView (UI.Helpers.testView <| InProgress 4)


main =
  Runner.program
    [ selectElementSpec
    ]