module UI.GuessTests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Elmer
import Elmer.Html as Markup
import Elmer.Html.Event as Event
import Elmer.Html.Matchers exposing (element, hasText)
import Elmer.Spy as Spy exposing (Spy)
import Elmer.Spy.Matchers exposing (wasCalledWith, typedArg)
import UI
import Core.Types exposing (GuessFeedback(..), Color(..))


playSpy : GuessFeedback -> Spy
playSpy feedback =
  Spy.createWith "play-spy" (\guess -> feedback)


guessTests : Test
guessTests =
  describe "when a guess is submitted"
  [ test "it executes the playGuess use case with the given guess" <|
    \() ->
      Elmer.given UI.defaultModel UI.view (UI.update <| Spy.callable "play-spy")
        |> Spy.use [ playSpy Wrong ]
        |> Markup.target "#guess-input"
        |> Event.input "rgby"
        |> Markup.target "#guess-submit"
        |> Event.click
        |> Spy.expect "play-spy" (
          wasCalledWith [ typedArg [ Red, Green, Blue, Yellow ] ]
        )
  , describe "when the guess is wrong"
    [ test "it reports that the guess is wrong" <|
      \() ->
        Elmer.given UI.defaultModel UI.view (UI.update <| Spy.callable "play-spy")
          |> Spy.use [ playSpy Wrong ]
          |> Markup.target "#guess-input"
          |> Event.input "rgby"
          |> Markup.target "#guess-submit"
          |> Event.click
          |> Markup.target "[data-guess-feedback]"
          |> Markup.expect (element <| hasText "Wrong.")
    ]
  , describe "when the guess is correct"
    [ test "it reports that the guess is correct" <|
      \() ->
        Elmer.given UI.defaultModel UI.view (UI.update <| Spy.callable "play-spy")
          |> Spy.use [ playSpy Correct ]
          |> Markup.target "#guess-input"
          |> Event.input "rgby"
          |> Markup.target "#guess-submit"
          |> Event.click
          |> Markup.target "[data-guess-feedback]"
          |> Markup.expect (element <| hasText "Correct!")
    ]
  ]
