module UI.GuessTests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Elmer exposing (TestState, Matcher, (<&&>), atIndex, hasLength, each)
import Elmer.Html as Markup exposing (HtmlElement)
import Elmer.Html.Event as Event
import Elmer.Html.Matchers exposing (element, elements, hasText, hasClass, hasAttribute, hasProperty)
import Elmer.Html.Element as Element
import Elmer.Spy as Spy exposing (Spy)
import Elmer.Spy.Matchers exposing (wasCalledWith, typedArg, functionArg)
import Elmer.Platform.Command as Command
import UI
import UI.Types exposing (Model, Msg)
import Core.Types exposing (GuessFeedback(..), Color(..), GameState(..), Code)
import Core.Clue as Clue
import TestHelpers exposing (..)


guessTests : Test
guessTests =
  describe "when a guess is submitted" <|
  let
    state =
      Elmer.given UI.defaultModel (UI.view InProgress) (UI.update <| Spy.callable "evaluator-spy")
        |> Spy.use [ evaluatorSpy <| wrongFeedback 0 0 ]
        |> selectGuess [ "red", "orange", "yellow", "green", "blue" ]
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
        |> Markup.target "[data-guess-input-element]"
        |> Markup.expect (elements <|
          each <| hasAttribute ("class", "empty")
        )
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
    [ test "it shows that the guess is correct" <|
      \() ->
        Correct
          |> expectFeedback [ ("black", 5) ]
    ]
  , describe "when no colors are correct"
    [ test "it shows that no colors are correct" <|
      \() ->
        wrongFeedback 0 0
          |> expectFeedback [ ("empty", 5) ]
    ]
  , describe "when some colors are correct"
    [ test "it shows how many colors are correct" <|
      \() ->
        wrongFeedback 3 0
          |> expectFeedback [ ("empty", 2), ("white", 3) ]
    ]
  , describe "when colors are correct and several are in the right position"
    [ test "it shows how many colors are in the right position and how many are not" <|
      \() ->
        wrongFeedback 3 2
          |> expectFeedback [ ("empty", 2), ("white", 1), ("black", 2) ]
    ]
  ]


guessListTests : Test
guessListTests =
  describe "when multiple guesses are submitted" <|
  let
    state =
      Elmer.given UI.defaultModel (UI.view InProgress) (UI.update <| Spy.callable "evaluator-spy")
        |> Spy.use [ evaluatorSpy <| wrongFeedback 0 0 ]
        |> selectGuess [ "red", "green", "blue", "yellow", "yellow" ]
        |> selectGuess [ "red", "green", "green", "yellow", "yellow" ]
        |> Spy.use [ evaluatorSpy Correct ]
        |> selectGuess [ "blue", "green", "green", "yellow", "yellow" ]
  in
  [ test "it shows the third guess first" <|
    \() ->
      state
        |> Markup.target "[data-guess-feedback]"
        |> Markup.expect (elements <| atIndex 0 <|
          expectGuess [ "blue", "green", "green", "yellow", "yellow" ] <&&>
          expectClue [ ("black", 5) ]
        )
  , test "it shows the second guess second" <|
    \() ->
      state
        |> Markup.target "[data-guess-feedback]"
        |> Markup.expect (elements <| atIndex 1 <|
          expectGuess [ "red", "green", "green", "yellow", "yellow" ] <&&>
          expectClue [ ("empty", 5) ]
        )
  , test "it shows the first guess last" <|
    \() ->
      state
        |> Markup.target "[data-guess-feedback]"
        |> Markup.expect (elements <| atIndex 2 <|
          expectGuess [ "red", "green", "blue", "yellow", "yellow" ] <&&>
          expectClue [ ("empty", 5) ]
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


expectFeedback : List (String, Int) -> GuessFeedback -> Expectation
expectFeedback clueElements feedback =
  Elmer.given UI.defaultModel (UI.view InProgress) (UI.update <| Spy.callable "evaluator-spy")
    |> Spy.use [ evaluatorSpy <| feedback ]
    |> selectGuess [ "red", "green", "blue", "yellow", "yellow" ]
    |> Markup.target "[data-guess-feedback]"
    |> Markup.expect (element <|
      expectClue clueElements
    )

expectClue : List (String, Int) -> Matcher (HtmlElement msg)
expectClue clueElements element =
  element
    |> Element.target "[data-clue-element]"
    |> elements (
      List.map expectClueElements clueElements
        |> expectAll
    )

expectClueElements : (String, Int) -> Matcher (List (HtmlElement msg))
expectClueElements (clueClass, expectedAmount) elements =
  List.filter (\element -> Expect.pass == hasAttribute ("class", clueClass) element) elements
    |> List.length
    |> Expect.equal expectedAmount


expectGuess : List String -> Matcher (HtmlElement msg)
expectGuess cssCode element =
  element
    |> Element.target "[data-guess-element]"
    |> elements (
      List.indexedMap expectGuessElement cssCode
        |> expectAll
    )

expectGuessElement : Int -> String -> Matcher (List (HtmlElement msg))
expectGuessElement index className =
  atIndex index <| hasAttribute ("class", className)


selectGuess : List String -> TestState Model Msg -> TestState Model Msg
selectGuess elements testState =
  List.indexedMap selectGuessElement elements
    |> foldStates testState
    |> Markup.target "#submit-guess"
    |> Event.click


selectGuessElement : Int -> String -> TestState Model Msg -> TestState Model Msg
selectGuessElement position class testState =
  testState
    |> Markup.target ("[data-guess-input='" ++ toString position ++ "'] [class='" ++ class ++ "']")
    |> Event.click
