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
import UI.TestHelpers as UIHelpers
import Core.Types exposing (GuessEvaluator, GuessResult(..), Color(..), GameState(..), Code)
import Core.Clue as Clue
import TestHelpers exposing (..)


guessTests : Test
guessTests =
  describe "when a guess is submitted" <|
  let
    state =
      Elmer.given (testModel 5) testView (testUpdate <| Spy.callable "evaluator-spy")
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
          expectGuessed [ "red", "orange", "yellow", "green", "blue" ]
        )
  ]

partialGuessTests : Test
partialGuessTests =
  let
    state =
      Elmer.given (testModel 3) testView (testUpdate <| (\_ _ -> Cmd.none))
  in
  describe "when a partial guess is submitted"
  [ test "it identifies elements that the user needs to select" <|
    \() ->
      state
        |> selectGuessElements [ Nothing, Just "red", Nothing ]
        |> Markup.target "[data-guess-input-element]"
        |> Markup.expect (elements <|
          (atIndex 0 <| hasAttribute ("class", "needs-selection-odd")) <&&>
          (atIndex 1 <| hasAttribute ("class", "red")) <&&>
          (atIndex 2 <| hasAttribute ("class", "needs-selection-odd"))
        )
  , test "it switches class every other attempt to submit" <|
    \() ->
      state
        |> selectGuessElements [ Nothing, Just "red", Nothing ]
        |> selectGuessElements [ Nothing, Just "red", Nothing ]
        |> Markup.target "[data-guess-input-element]"
        |> Markup.expect (elements <|
          (atIndex 0 <| hasAttribute ("class", "needs-selection-even")) <&&>
          (atIndex 1 <| hasAttribute ("class", "red")) <&&>
          (atIndex 2 <| hasAttribute ("class", "needs-selection-even"))
        )
  , describe "when guessing again after submitting a completed partial selection"
    [ test "it does not show needs selection" <|
      \() ->
        state
          |> selectGuessElements [ Nothing, Just "red", Nothing ]
          |> selectGuess [ "red", "red", "red" ]
          |> Markup.target "[data-guess-input-element]"
          |> Markup.expect (elements <|
            (atIndex 0 <| hasAttribute ("class", "empty")) <&&>
            (atIndex 1 <| hasAttribute ("class", "empty")) <&&>
            (atIndex 2 <| hasAttribute ("class", "empty"))
          )
    ]
  ]

remainingGuessesTests : Test
remainingGuessesTests =
  describe "remaining guesses"
  [ test "it shows the guesses remaining" <|
    \() ->
      Elmer.given (testModel 3) testView (testUpdate (\_ _ -> Cmd.none))
        |> Markup.target "#game-progress"
        |> Markup.expect (element <| hasText "4 guesses remain!")
  , describe "when 1 guess remains"
    [ test "it shows that 1 guess remains" <|
      \() ->
        Elmer.given (testModel 3) (UI.view <| InProgress 1) (testUpdate (\_ _ -> Cmd.none))
          |> Markup.target "#game-progress"
          |> Markup.expect (element <| hasText "Last guess!")
    ]
  ]

cluePresentationTests : Test
cluePresentationTests =
  describe "when there is a clue"
  [ describe "when the guess is correct"
    [ test "it shows that the guess is correct" <|
      \() ->
        Right
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


guessHistoryTests : Test
guessHistoryTests =
  describe "when multiple guesses are submitted" <|
  let
    state =
      Elmer.given (testModel 3) testView (testUpdate <| Spy.callable "evaluator-spy")
        |> Spy.use [ evaluatorSpy <| wrongFeedback 0 0 ]
        |> selectGuess [ "red", "green", "blue" ]
        |> selectGuess [ "red", "green", "green" ]
        |> Spy.use [ evaluatorSpy Right ]
        |> selectGuess [ "blue", "green", "green" ]
  in
  [ test "it shows the third guess first" <|
    \() ->
      state
        |> Markup.target "[data-guess-feedback]"
        |> Markup.expect (elements <| atIndex 0 <|
          expectGuessed [ "blue", "green", "green" ] <&&>
          expectClue [ ("black", 3) ]
        )
  , test "it shows the second guess second" <|
    \() ->
      state
        |> Markup.target "[data-guess-feedback]"
        |> Markup.expect (elements <| atIndex 1 <|
          expectGuessed [ "red", "green", "green" ] <&&>
          expectClue [ ("empty", 3) ]
        )
  , test "it shows the first guess last" <|
    \() ->
      state
        |> Markup.target "[data-guess-feedback]"
        |> Markup.expect (elements <| atIndex 2 <|
          expectGuessed [ "red", "green", "blue" ] <&&>
          expectClue [ ("empty", 3) ]
        )
  , describe "when the game is reset"
    [ test "it clears the history" <|
      \() ->
        state
          |> Elmer.expectModel (\model ->
            Elmer.given model (UI.view <| Won 87) (testUpdate <| (\_ _ -> Cmd.none))
              |> Markup.target "#new-game"
              |> Event.click
              |> Markup.target "[data-guess-feedback]"
              |> Markup.expect (elements <| hasLength 0)
          )
    ]
  ]


testModel : Int -> Model
testModel codeLength =
  UI.defaultModel { codeLength = codeLength, colors = testColors }


testColors : List Color
testColors =
  [ Red, Orange, Yellow, Blue, Green ]


testUpdate : GuessEvaluator Msg msg -> Msg -> Model -> (Model, Cmd msg)
testUpdate evaluator =
  let
    dependencies = UIHelpers.viewDependencies
  in
    UIHelpers.testUpdate <|
      { dependencies | guessEvaluator = evaluator }


testView =
  UI.view <| InProgress 4


evaluatorSpy : GuessResult -> Spy
evaluatorSpy feedback =
  Spy.createWith "evaluator-spy" <|
    \tagger _ ->
      tagger feedback
        |> Command.fake


wrongFeedback : Int -> Int -> GuessResult
wrongFeedback colorsCorrect positionsCorrect =
  Clue.with colorsCorrect positionsCorrect
    |> Wrong


expectFeedback : List (String, Int) -> GuessResult -> Expectation
expectFeedback clueElements feedback =
  Elmer.given (testModel 5) testView (testUpdate <| Spy.callable "evaluator-spy")
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


expectGuessed : List String -> Matcher (HtmlElement msg)
expectGuessed cssCode element =
  element
    |> Element.target "[data-guess-element]"
    |> elements (
      List.indexedMap expectGuessedElement cssCode
        |> expectAll
    )

expectGuessedElement : Int -> String -> Matcher (List (HtmlElement msg))
expectGuessedElement index className =
  atIndex index <| hasAttribute ("class", className)


selectGuessElements : List (Maybe String) -> TestState Model Msg -> TestState Model Msg
selectGuessElements elements testState =
  List.indexedMap selectGuessElement elements
    |> foldStates testState
    |> Markup.target "#submit-guess"
    |> Event.click


selectGuess : List String -> TestState Model Msg -> TestState Model Msg
selectGuess elements testState =
  List.map Just elements
    |> flip selectGuessElements testState


selectGuessElement : Int -> Maybe String -> TestState Model Msg -> TestState Model Msg
selectGuessElement position maybeClass testState =
  case maybeClass of
    Just class ->
      testState
        |> Markup.target ("[data-guess-input='" ++ toString position ++ "'] [class='" ++ class ++ "']")
        |> Event.click
    Nothing ->
      testState
