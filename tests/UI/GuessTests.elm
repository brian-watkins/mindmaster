module UI.GuessTests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Elmer exposing ((<&&>), atIndex)
import Elmer.Html as Markup
import Elmer.Html.Event as Event
import Elmer.Html.Matchers exposing (element, elements, hasText)
import Elmer.Spy as Spy exposing (Spy)
import Elmer.Spy.Matchers exposing (wasCalledWith, typedArg)
import UI
import Core.Types exposing (GuessFeedback(..), Color(..))
import Core.Clue as Clue

playSpy : GuessFeedback -> Spy
playSpy feedback =
  Spy.createWith "play-spy" (\guess -> feedback)


guessTests : Test
guessTests =
  describe "when a guess is submitted"
  [ test "it executes the playGuess use case with the given guess" <|
    \() ->
      Elmer.given UI.defaultModel UI.view (UI.update <| Spy.callable "play-spy")
        |> Spy.use [ playSpy <| wrongFeedback 0 ]
        |> Markup.target "#guess-input"
        |> Event.input "rgby"
        |> Markup.target "#guess-submit"
        |> Event.click
        |> Spy.expect "play-spy" (
          wasCalledWith [ typedArg [ Red, Green, Blue, Yellow ] ]
        )
  , describe "when the guess is wrong" <|
    let
      state =
        Elmer.given UI.defaultModel UI.view (UI.update <| Spy.callable "play-spy")
          |> Spy.use [ playSpy <| wrongFeedback 2 ]
          |> Markup.target "#guess-input"
          |> Event.input "rgby"
          |> Markup.target "#guess-submit"
          |> Event.click
    in
    [ test "it records the guess" <|
      \() ->
        state
          |> Markup.target "[data-guess-feedback]"
          |> Markup.expect (element <| hasText "rgby")
    , test "it reports that the guess is wrong with a hint" <|
      \() ->
        state
          |> Markup.target "[data-guess-feedback]"
          |> Markup.expect (element <| hasText "Wrong. 2 colors correct.")
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


guessListTests : Test
guessListTests =
  describe "when multiple guesses are submitted" <|
  let
    state =
      Elmer.given UI.defaultModel UI.view (UI.update <| Spy.callable "play-spy")
        |> Spy.use [ playSpy <| wrongFeedback 0 ]
        |> Markup.target "#guess-input"
        |> Event.input "rgby"
        |> Markup.target "#guess-submit"
        |> Event.click
        |> Markup.target "#guess-input"
        |> Event.input "rggy"
        |> Markup.target "#guess-submit"
        |> Event.click
        |> Spy.use [ playSpy Correct ]
        |> Markup.target "#guess-input"
        |> Event.input "bggy"
        |> Markup.target "#guess-submit"
        |> Event.click
  in
  [ test "it shows the third guess first" <|
    \() ->
      state
        |> Markup.target "[data-guess-feedback]"
        |> Markup.expect (elements <| atIndex 0 <|
          hasText "bggy" <&&>
          hasText "Correct!"
        )
  , test "it shows the second guess second" <|
    \() ->
      state
        |> Markup.target "[data-guess-feedback]"
        |> Markup.expect (elements <| atIndex 1 <|
          hasText "rggy" <&&>
          hasText "Wrong. 0 colors correct."
        )
  , test "it shows the first guess last" <|
    \() ->
      state
        |> Markup.target "[data-guess-feedback]"
        |> Markup.expect (elements <| atIndex 2 <|
          hasText "rgby" <&&>
          hasText "Wrong. 0 colors correct."
        )
  ]


wrongFeedback : Int -> GuessFeedback
wrongFeedback colorsCorrect =
  Clue.withColorsCorrect colorsCorrect
    |> Wrong
