module UI.GuessTests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Elmer exposing (TestState, Matcher, expectAll, atIndex, hasLength, each)
import Elmer.Html as Markup exposing (HtmlElement)
import Elmer.Html.Event as Event
import Elmer.Html.Matchers exposing (element, elements, hasText, hasClass, hasAttribute)
import Elmer.Html.Element as Element
import Elmer.Html.Selector exposing (..)
import Elmer.Spy as Spy exposing (Spy, andCallFake)
import Elmer.Spy.Matchers exposing (wasCalledWith, typedArg, functionArg)
import Elmer.Command as Command
import UI
import UI.View
import UI.Types exposing (Model, Msg)
import UI.TestHelpers as UIHelpers
import Game.Types exposing (GuessEvaluator, GuessResult(..), Color(..), GameState(..), Code)
import Game.Entity.Clue as Clue
import TestHelpers exposing (..)


guessTests : Test
guessTests =
  describe "when a guess is submitted" <|
  let
    fake =
      Spy.observe (\_ -> emptyEvaluator)
        |> andCallFake (evaluatorFake <| wrongFeedback 0 0)

    state =
      Elmer.given (testModel 5) testView (testUpdate <| Spy.inject (\_ -> emptyEvaluator))
        |> Spy.use [ fake ]
        |> selectGuess [ "red", "orange", "yellow", "green", "blue" ]
  in
  [ test "it executes the playGuess use case with the given guess" <|
    \() ->
      state
        |> Spy.expect (\_ -> emptyEvaluator) (
          wasCalledWith [ typedArg [ Red, Orange, Yellow, Green, Blue ] ]
        )
  , test "it clears the guess input" <|
    \() ->
      state
        |> Markup.target << by [ attributeName "data-guess-input-element" ]
        |> Markup.expect (elements <|
          each <| hasAttribute ("class", "empty")
        )
  , test "it shows the guess in the list" <|
    \() ->
      state
        |> Markup.target << by [ attributeName "data-guess-feedback" ]
        |> Markup.expect (element <|
          expectGuessed [ "red", "orange", "yellow", "green", "blue" ]
        )
  ]

partialGuessTests : Test
partialGuessTests =
  let
    state =
      Elmer.given (testModel 3) testView (testUpdate emptyEvaluator)
  in
  describe "when a partial guess is submitted"
  [ test "it identifies elements that the user needs to select" <|
    \() ->
      state
        |> selectGuessElements [ Nothing, Just "red", Nothing ]
        |> Markup.target << by [ attributeName "data-guess-input-element" ]
        |> Markup.expect (elements <| expectAll
          [ atIndex 0 <| hasAttribute ("class", "needs-selection-odd")
          , atIndex 1 <| hasAttribute ("class", "red")
          , atIndex 2 <| hasAttribute ("class", "needs-selection-odd")
          ]
        )
  , test "it switches class every other attempt to submit" <|
    \() ->
      state
        |> selectGuessElements [ Nothing, Just "red", Nothing ]
        |> selectGuessElements [ Nothing, Just "red", Nothing ]
        |> Markup.target << by [ attributeName "data-guess-input-element" ]
        |> Markup.expect (elements <| expectAll
          [ atIndex 0 <| hasAttribute ("class", "needs-selection-even")
          , atIndex 1 <| hasAttribute ("class", "red")
          , atIndex 2 <| hasAttribute ("class", "needs-selection-even")
          ]
        )
  , describe "when guessing again after submitting a completed partial selection"
    [ test "it does not show needs selection" <|
      \() ->
        state
          |> selectGuessElements [ Nothing, Just "red", Nothing ]
          |> selectGuess [ "red", "red", "red" ]
          |> Markup.target << by [ attributeName "data-guess-input-element" ]
          |> Markup.expect (elements <| expectAll
            [ atIndex 0 <| hasAttribute ("class", "empty")
            , atIndex 1 <| hasAttribute ("class", "empty")
            , atIndex 2 <| hasAttribute ("class", "empty")
            ]
          )
    ]
  ]

remainingGuessesTests : Test
remainingGuessesTests =
  describe "remaining guesses"
  [ test "it shows the guesses remaining" <|
    \() ->
      Elmer.given (testModel 3) testView (testUpdate emptyEvaluator)
        |> Markup.target << by [ id "game-progress" ]
        |> Markup.expect (element <| hasText "4 guesses remain!")
  , describe "when 1 guess remains"
    [ test "it shows that 1 guess remains" <|
      \() ->
        Elmer.given (testModel 3) (UIHelpers.testView <| InProgress 1) (testUpdate emptyEvaluator)
          |> Markup.target << by [ id "game-progress" ]
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
    selector =
      \guess ->
        if guess == [ Blue, Green, Green ] then
          UI.guessResultTagger guess Right
            |> Command.fake
        else
          UI.guessResultTagger guess (wrongFeedback 0 0)
            |> Command.fake

    wrongEvaluator =
      Spy.observe (\_ -> emptyEvaluator)
        |> Spy.andCallFake (evaluatorFake <| wrongFeedback 0 0)

    rightEvaluator =
      Spy.observe (\_ -> emptyEvaluator)
        |> andCallFake (evaluatorFake Right)
    state =
      Elmer.given (testModel 3) testView (testUpdate <| Spy.inject (\_ -> emptyEvaluator))
        |> Spy.use [ wrongEvaluator ]
        |> selectGuess [ "red", "green", "blue" ]
        |> selectGuess [ "red", "green", "green" ]
        |> Spy.use [ rightEvaluator ]
        |> selectGuess [ "blue", "green", "green" ]
  in
  [ test "it shows the third guess first" <|
    \() ->
      state
        |> Markup.target << by [ attributeName "data-guess-feedback" ]
        |> Markup.expect (elements <| atIndex 0 <| expectAll
          [ expectGuessed [ "blue", "green", "green" ]
          , expectClue [ ("black", 3) ]
          ]
        )
  , test "it shows the second guess second" <|
    \() ->
      state
        |> Markup.target << by [ attributeName "data-guess-feedback" ]
        |> Markup.expect (elements <| atIndex 1 <| expectAll
          [ expectGuessed [ "red", "green", "green" ]
          , expectClue [ ("empty", 3) ]
          ]
        )
  , test "it shows the first guess last" <|
    \() ->
      state
        |> Markup.target << by [ attributeName "data-guess-feedback" ]
        |> Markup.expect (elements <| atIndex 2 <| expectAll
          [ expectGuessed [ "red", "green", "blue" ]
          , expectClue [ ("empty", 3) ]
          ]
        )
  , describe "when the game is reset"
    [ test "it clears the history" <|
      \() ->
        state
          |> Elmer.expectModel (\model ->
            Elmer.given model (UIHelpers.testView <| Won 87) (testUpdate emptyEvaluator)
              |> Markup.target << by [ id "new-game" ]
              |> Event.click
              |> Markup.target << by [ attributeName "data-guess-feedback" ]
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


testUpdate : GuessEvaluator msg -> Msg -> Model -> (Model, Cmd msg)
testUpdate evaluator =
  let
    dependencies = UIHelpers.viewDependencies
  in
    UIHelpers.testUpdate <|
      { dependencies | guessEvaluator = evaluator }


testView =
  UI.View.with <| InProgress 4


emptyEvaluator : Code -> Cmd Msg
emptyEvaluator _ =
  Cmd.none


evaluatorFake : GuessResult -> Code -> Cmd Msg
evaluatorFake feedback guess =
  UI.guessResultTagger guess feedback
    |> Command.fake


wrongFeedback : Int -> Int -> GuessResult
wrongFeedback colorsCorrect positionsCorrect =
  Clue.with colorsCorrect positionsCorrect
    |> Wrong


expectFeedback : List (String, Int) -> GuessResult -> Expectation
expectFeedback clueElements feedback =
  let
    fake = 
      Spy.observe (\_ -> emptyEvaluator)
        |> andCallFake (evaluatorFake feedback)
  in
  Elmer.given (testModel 5) testView (testUpdate <| Spy.inject (\_ -> emptyEvaluator))
    |> Spy.use [ fake ]
    |> selectGuess [ "red", "green", "blue", "yellow", "yellow" ]
    |> Markup.target << by [ attributeName "data-guess-feedback" ]
    |> Markup.expect (element <|
      expectClue clueElements
    )

expectClue : List (String, Int) -> Matcher (HtmlElement msg)
expectClue clueElements element =
  element
    |> Element.target << by [ attributeName "data-clue-element" ]
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
    |> Element.target << by [ attributeName "data-guess-element" ]
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
    |> Markup.target << by [ id "submit-guess" ]
    |> Event.click


selectGuess : List String -> TestState Model Msg -> TestState Model Msg
selectGuess elements testState =
  selectGuessElements (List.map Just elements) testState


selectGuessElement : Int -> Maybe String -> TestState Model Msg -> TestState Model Msg
selectGuessElement position maybeClass testState =
  case maybeClass of
    Just class ->
      testState
        |> Markup.target 
          << descendantsOf [ attribute ("data-guess-input", String.fromInt position) ]
          << by [ attribute ("class", class) ]
        |> Event.click
    Nothing ->
      testState
