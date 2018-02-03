module UI.GuessTests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Elmer exposing ((<&&>), atIndex)
import Elmer.Html as Markup exposing (HtmlElement)
import Elmer.Html.Event as Event
import Elmer.Html.Matchers exposing (element, elements, hasText, hasClass, hasAttribute, hasProperty)
import Elmer.Html.Element as Element
import Elmer.Spy as Spy exposing (Spy)
import Elmer.Spy.Matchers exposing (wasCalledWith, typedArg, functionArg)
import Elmer.Platform.Command as Command
import UI
import Core.Types exposing (GuessFeedback(..), Color(..), GameState(..), Code)
import Core.Clue as Clue


guessTests : Test
guessTests =
  describe "when a guess is submitted" <|
  let
    state =
      Elmer.given UI.defaultModel (UI.view InProgress) (UI.update <| Spy.callable "evaluator-spy")
        |> Spy.use [ evaluatorSpy <| wrongFeedback 0 0 ]
        |> Markup.target "#guess-input"
        |> Event.input "roygb"
        |> Markup.target "#guess-submit"
        |> Event.click
  in
  [ test "it executes the playGuess use case with the given guess" <|
    \() ->
      state
        |> Spy.expect "evaluator-spy" (
          wasCalledWith [ functionArg, typedArg [ Red, Orange, Yellow, Green, Blue ] ]
        )
  , test "it clears the guess input" <|
    \() ->
      state
        |> Markup.target "#guess-input"
        |> Markup.expect (element <| hasProperty ("value", ""))
  , test "it shows the guess in the list" <|
    \() ->
      state
        |> Markup.target "[data-guess-feedback]"
        |> Markup.expect (element <|
          expectGuess [ "red", "orange", "yellow", "green", "blue" ]
        )
  ]


cluePresentationTests : Test
cluePresentationTests =
  describe "when there is a clue"
  [ describe "when the guess is correct"
    [ test "it reports that the guess is correct" <|
      \() ->
        Correct
          |> expectClue "Correct!"
    ]
  , describe "when no colors are correct"
    [ test "it says no colors are correct" <|
      \() ->
        wrongFeedback 0 0
          |> expectClue "Wrong. 0 colors correct."
    ]
  , describe "when one color is correct"
    [ test "it says one color is correct" <|
      \() ->
        wrongFeedback 1 0
          |> expectClue "Wrong. 1 color correct."
    ]
  , describe "when several colors are correct but none are in the right position"
    [ test "it says how many colors are correct" <|
      \() ->
        wrongFeedback 3 0
          |> expectClue "Wrong. 3 colors correct."
    ]
  , describe "when colors are correct and one is in the right position"
    [ test "it says one is in the right position" <|
      \() ->
        wrongFeedback 2 1
          |> expectClue "Wrong. 2 colors correct. 1 is in the right position."
    ]
  , describe "when colors are correct and several are in the right position"
    [ test "it says how many colors are in the right position and how many are not" <|
      \() ->
        wrongFeedback 3 2
          |> expectClue "Wrong. 3 colors correct. 2 are in the right position."
    ]
  ]


guessListTests : Test
guessListTests =
  describe "when multiple guesses are submitted" <|
  let
    state =
      Elmer.given UI.defaultModel (UI.view InProgress) (UI.update <| Spy.callable "evaluator-spy")
        |> Spy.use [ evaluatorSpy <| wrongFeedback 0 0 ]
        |> Markup.target "#guess-input"
        |> Event.input "rgby"
        |> Markup.target "#guess-submit"
        |> Event.click
        |> Markup.target "#guess-input"
        |> Event.input "rggy"
        |> Markup.target "#guess-submit"
        |> Event.click
        |> Spy.use [ evaluatorSpy Correct ]
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
          expectGuess [ "blue", "green", "green", "yellow" ] <&&>
          hasText "Correct!"
        )
  , test "it shows the second guess second" <|
    \() ->
      state
        |> Markup.target "[data-guess-feedback]"
        |> Markup.expect (elements <| atIndex 1 <|
          expectGuess [ "red", "green", "green", "yellow" ] <&&>
          hasText "Wrong. 0 colors correct."
        )
  , test "it shows the first guess last" <|
    \() ->
      state
        |> Markup.target "[data-guess-feedback]"
        |> Markup.expect (elements <| atIndex 2 <|
          expectGuess [ "red", "green", "blue", "yellow" ] <&&>
          hasText "Wrong. 0 colors correct."
        )
  ]


evaluatorSpy : GuessFeedback -> Spy
evaluatorSpy feedback =
  Spy.createWith "evaluator-spy" <|
    \tagger _ ->
      tagger feedback
        |> Command.fake


wrongFeedback : Int -> Int -> GuessFeedback
wrongFeedback colorsCorrect positionsCorrect =
  Clue.with colorsCorrect positionsCorrect
    |> Wrong


expectClue : String -> GuessFeedback -> Expectation
expectClue clue feedback =
  Elmer.given UI.defaultModel (UI.view InProgress) (UI.update <| Spy.callable "evaluator-spy")
    |> Spy.use [ evaluatorSpy <| feedback ]
    |> Markup.target "#guess-input"
    |> Event.input "rgby"
    |> Markup.target "#guess-submit"
    |> Event.click
    |> Markup.target "[data-guess-feedback]"
    |> Markup.expect (element <|
      expectGuess [ "red", "green", "blue", "yellow" ] <&&>
      hasText clue
    )

expectGuess : List String -> HtmlElement msg -> Expectation
expectGuess cssCode element =
  element
    |> Element.target "[data-guess-element]"
    |> elements (
      List.indexedMap expectGuessElement cssCode
        |> List.foldl (<&&>) (\_ -> Expect.pass)
    )

expectGuessElement : Int -> String -> Elmer.Matcher (List (HtmlElement msg))
expectGuessElement index className =
  atIndex index <| hasAttribute ("class", className)
