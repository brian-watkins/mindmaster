module UI.GuessSpec exposing (main)

import Spec exposing (..)
import Spec.Setup as Setup
import Spec.Observer as Observer
import Spec.Claim exposing (..)
import Spec.Markup as Markup
import Spec.Markup.Selector exposing (..)
import Spec.Markup.Event as Event
import Spec.Extra exposing (..)
import Runner
import UI.Types as UITypes
import UI.Helpers
import Game.Types exposing (..)
import Game.Entity.Clue as Clue


guessSpecs : Spec UITypes.Model UITypes.Msg
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
              |> expect (isListWhere
                [ hasClass "empty"
                , hasClass "empty"
                , hasClass "empty"
                , hasClass "empty"
                , hasClass "empty"
                ]
              )
          )
        , it "shows the guess in the list" (
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
          |> expect (isListWhere
            [ hasClass "needs-selection-odd"
            , hasClass "red"
            , hasClass "needs-selection-odd"
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
          |> expect (isListWhere
            [ hasClass "needs-selection-even"
            , hasClass "red"
            , hasClass "needs-selection-even"
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
          |> expect (isListWhere
            [ hasClass "empty"
            , hasClass "empty"
            , hasClass "empty"
            ]
          )
      )
    )
  ]


guessesRemainingSpec : Spec UITypes.Model UITypes.Msg
guessesRemainingSpec =
  Spec.describe "guesses remaining"
  [ scenario "multiple guesses remain" (
      given (
        testSubject 3 4
      )
      |> it "shows the remaining guesses" (
        Markup.observeElement
          |> Markup.query << by [ id "game-progress" ]
          |> expectElement (hasText "4 guesses remain!")
      )
    )
  , scenario "one guess remains" (
      given (
        testSubject 3 1
      )
      |> it "shows this is the last guess" (
        Markup.observeElement
          |> Markup.query << by [ id "game-progress" ]
          |> expectElement (hasText "Last guess!")
      )
    )
  ]


clueSpec : Spec UITypes.Model UITypes.Msg
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


guessHistorySpec : Spec UITypes.Model UITypes.Msg
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
  Setup.initWithModel (UI.Helpers.testModel positions)
    |> Setup.withUpdate (UI.Helpers.testUpdate evaluator)
    |> Setup.withView (testView guessesRemaining)


expectGuessAt index cssCodes =
  Markup.observeElements
    |> Markup.query
        << descendantsOf [ attribute ("data-guess-feedback", String.fromInt index) ]
        << by [ attributeName "data-guess-element" ]
    |> expect (isListWhere <|
      List.map hasClass cssCodes
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