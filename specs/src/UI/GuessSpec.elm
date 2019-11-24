module UI.GuessSpec exposing (main)

import Spec exposing (Spec)
import Spec.Scenario exposing (..)
import Spec.Subject as Subject
import Spec.Observer as Observer
import Spec.Claim exposing (..)
import Spec.Markup as Markup
import Spec.Markup.Selector exposing (..)
import Spec.Markup.Event as Event
import Spec.Witness as Witness exposing (Witness)
import Spec.Extra exposing (..)
import Runner
import UI.Types exposing (..)
import UI.Helpers
import Game.Types exposing (..)
import Game.Entity.Clue as Clue


guessSpecs : Spec Model Msg
guessSpecs =
  Spec.describe "Make a Guess"
  [ scenario "a valid guess" (
      given (
        testSubject 5 4
      )
      |> whenSubmitGuess [ Just "red", Just "orange", Just "yellow", Just "green", Just "blue" ]
      |> observeThat
        [ UI.Helpers.itEvaluatesTheGuess [ "red", "orange", "yellow", "green", "blue" ]
        , it "clears the guess input" (
            Markup.observeElements
              |> Markup.query << by [ attributeName "data-guess-input-element" ]
              |> expect (isList
                [ Markup.hasAttribute ("class", "empty")
                , Markup.hasAttribute ("class", "empty")
                , Markup.hasAttribute ("class", "empty")
                , Markup.hasAttribute ("class", "empty")
                , Markup.hasAttribute ("class", "empty")
                ]
              )
          )
        , it "shows the guess is the list" (
            expectGuessAt 0 [ "red", "orange", "yellow", "green", "blue" ]
        )
      ]
    )
  , scenario "a partial guess" (
      given (
        testSubject 3 4
      )
      |> whenSubmitGuess [ Nothing, Just "red", Nothing ]
      |> it "identifies elements the user needs to select" (
        Markup.observeElements
          |> Markup.query << by [ attributeName "data-guess-input-element" ]
          |> expect (isList
            [ Markup.hasAttribute ("class", "needs-selection-odd" )
            , Markup.hasAttribute ("class", "red" )
            , Markup.hasAttribute ("class", "needs-selection-odd" )
            ]
          )
      )
    )
  , scenario "multiple partial guesses" (
      given (
        testSubject 3 4
      )
      |> whenSubmitGuess [ Nothing, Just "red", Nothing ]
      |> whenSubmitGuess [ Nothing, Just "red", Nothing ]
      |> it "switches the class on the elements the user needs to select" (
        Markup.observeElements
          |> Markup.query << by [ attributeName "data-guess-input-element" ]
          |> expect (isList
            [ Markup.hasAttribute ("class", "needs-selection-even" )
            , Markup.hasAttribute ("class", "red" )
            , Markup.hasAttribute ("class", "needs-selection-even" )
            ]
          )
      )
    )
  , scenario "complete guess after partial guess" (
      given (
        testSubject 3 4
      )
      |> whenSubmitGuess [ Nothing, Just "red", Nothing ]
      |> whenSubmitGuess [ Just "red", Just "red", Just "red" ]
      |> it "clears the inputs" (
        Markup.observeElements
          |> Markup.query << by [ attributeName "data-guess-input-element" ]
          |> expect (isList
            [ Markup.hasAttribute ("class", "empty" )
            , Markup.hasAttribute ("class", "empty" )
            , Markup.hasAttribute ("class", "empty" )
            ]
          )
      )
    )
  ]


guessesRemainingSpec : Spec Model Msg
guessesRemainingSpec =
  Spec.describe "guesses remaining"
  [ scenario "multiple guesses remain" (
      given (
        testSubject 3 4
      )
      |> it "shows the remaining guesses" (
        Markup.observeElement
          |> Markup.query << by [ id "game-progress" ]
          |> expect (Markup.hasText "4 guesses remain!")
      )
    )
  , scenario "one guess remains" (
      given (
        testSubject 3 1
      )
      |> it "shows this is the last guess" (
        Markup.observeElement
          |> Markup.query << by [ id "game-progress" ]
          |> expect (Markup.hasText "Last guess!")
      )
    )
  ]


clueSpec : Spec Model Msg
clueSpec =
  Spec.describe "clues"
  [ scenario "the guess is correct" (
      givenGuessWithResult Right
        |> itProvidesFeedback [ ("black", 5) ]
    )
  , scenario "no colors are correct" (
      givenGuessWithResult (wrongFeedback 0 0)
        |> itProvidesFeedback [ ("empty", 5) ]
    )
  , scenario "some colors are correct" (
      givenGuessWithResult (wrongFeedback 3 0)
        |> itProvidesFeedback [ ("empty", 2), ("white", 3) ]
    )
  , scenario "some colors are correct and some are in the correct position" (
      givenGuessWithResult (wrongFeedback 3 2)
        |> itProvidesFeedback [ ("empty", 2), ("white", 1), ("black", 2) ]
    )
  ]


guessHistorySpec : Spec Model Msg
guessHistorySpec =
  Spec.describe "guess history"
  [ scenario "multiple guesses are submitted" (
      given (
        testSubjectWithEvaluator 3 4 (\code -> 
          if code == [ Red, Red, Red ] then
            Right
          else
            wrongFeedback 0 0
        )
      )
      |> whenSubmitGuess [ Just "yellow", Just "yellow", Just "yellow" ]
      |> whenSubmitGuess [ Just "blue", Just "blue", Just "blue" ]
      |> whenSubmitGuess [ Just "red", Just "red", Just "red" ]
      |> observeThat
        [ it "shows the third guess first" (
            expectGuessAt 0 [ "red", "red", "red" ]
          )
        , itProvidesFeedbackAt 0 [ ("black", 3) ]
        , it "shows the second guess second" (
            expectGuessAt 1 [ "blue", "blue", "blue" ]
          )
        , itProvidesFeedbackAt 1 [ ("empty", 3) ]
        , it "shows the first guess last" (
            expectGuessAt 2 [ "yellow", "yellow", "yellow" ]
          )
        , itProvidesFeedbackAt 2 [ ("empty", 3) ]
        ]
    ) 
  ]


itProvidesFeedback indicators =
  itProvidesFeedbackAt 0 indicators


itProvidesFeedbackAt index indicators =
  observeThat <|
    List.map (\(className, expectedNumber) ->
      it ("shows " ++ String.fromInt expectedNumber ++ " " ++ className ++ " indicators") (
        Markup.observeElements
          |> Markup.query
            << descendantsOf [ attribute ("data-guess-feedback", String.fromInt index) ]
            << by [ attributeName "data-clue-element", attribute ("class", className) ]
          |> expect (isListWithLength expectedNumber)
      )
    ) indicators
  

givenGuessWithResult guessResult =
  given (
    testSubjectWithResult 5 4 guessResult
  )
  |> whenSubmitGuess [ Just "red", Just "green", Just "blue", Just "yellow", Just "yellow" ]


testSubject positions guessesRemaining =
  testSubjectWithResult positions guessesRemaining (wrongFeedback 0 0)


testSubjectWithResult positions guessesRemaining result =
  testSubjectWithEvaluator positions guessesRemaining (\_ -> result)


testSubjectWithEvaluator positions guessesRemaining evaluator =
  Subject.initWithModel (UI.Helpers.testModel positions)
    |> Witness.forUpdate (UI.Helpers.testUpdate evaluator)
    |> Subject.withView (testView guessesRemaining)


expectGuessAt index cssCodes =
  Markup.observeElements
    |> Markup.query
        << descendantsOf [ attribute ("data-guess-feedback", String.fromInt index) ]
        << by [ attributeName "data-guess-element" ]
    |> expect (isList <|
      List.map (\c -> Markup.hasAttribute ("class", c)) cssCodes  
    )


whenSubmitGuess colors =
  when ("" ++ (String.join ", " <| List.map (Maybe.withDefault "[Nothing]") colors) ++ " is selected") <|
    List.append (List.concat <| List.indexedMap selectGuessElement colors)
      [ Markup.target << by [ id "submit-guess" ]
      , Event.click
      ]


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


wrongFeedback : Int -> Int -> GuessResult
wrongFeedback colorsCorrect positionsCorrect =
  Clue.with colorsCorrect positionsCorrect
    |> Wrong


testView guessesRemaining =
  UI.Helpers.testView <| InProgress guessesRemaining


main =
  Runner.program
    [ guessSpecs
    , guessesRemainingSpec
    , clueSpec
    , guessHistorySpec
    ]