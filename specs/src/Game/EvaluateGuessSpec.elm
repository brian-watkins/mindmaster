module Game.EvaluateGuessSpec exposing (main)

import Spec exposing (Spec)
import Spec.Scenario exposing (..)
import Spec.Subject as Subject
import Spec.Observer as Observer
import Spec.Command as Command
import Spec.Extra exposing (equals)
import Game
import Game.Action as Game
import Game.Entity.Clue as Clue
import Game.UseCases as UseCases
import Game.Types exposing (..)
import Runner


evaluateGuessSpec : Spec Model Msg
evaluateGuessSpec =
  Spec.describe "evaluate guess"
  [ scenario "no colors are corrent" (
      givenGameWithCode [ Blue ]
        |> whenAGuessIsEvaluated [ Yellow ]
        |> it "notifies the UI that zero colors are correct" (
          expectGuessResult <| wrong 0 0
        )
    )
  , scenario "one color is correct" (
      givenGameWithCode [ Blue, Yellow ]
        |> whenAGuessIsEvaluated [ Yellow, Red ]
        |> it "notifies the UI that one color is corrrect" (
          expectGuessResult <| wrong 1 0
        )
    )
  , scenario "more than one of the same color matching" (
      givenGameWithCode [ Blue, Blue, Yellow, Blue, Orange ]
        |> whenAGuessIsEvaluated [ Green, Red, Blue, Red, Blue ]
        |> it "only matches the number in the code" (
          expectGuessResult <| wrong 2 0
        )
    )
  , scenario "more than one color is correct" (
      givenGameWithCode [ Blue, Yellow, Red ]
        |> whenAGuessIsEvaluated [ Yellow, Blue, Green ]
        |> it "indicates the number of correct colors" (
          expectGuessResult <| wrong 2 0
        )
    )
  , scenario "one color is in the correct position" (
      givenGameWithCode [ Blue, Yellow, Yellow ]
        |> whenAGuessIsEvaluated [ Green, Yellow, Blue ]
        |> it "indicates that one color is in the correct position" (
          expectGuessResult <| wrong 2 1
        )
    )
  , scenario "more than one color is in the correct position" (
      givenGameWithCode [ Blue, Yellow, Yellow ]
        |> whenAGuessIsEvaluated [ Green, Yellow, Yellow ]
        |> it "indicates that multiple colors are in the correct position" (
          expectGuessResult <| wrong 2 2
        )
    )
  , scenario "the guess is correct" (
      givenGameWithCode [ Blue, Yellow, Yellow ]
        |> whenAGuessIsEvaluated [ Blue, Yellow, Yellow ]
        |> it "indicates that the guess is correct" (
          expectGuessResult Right
        )
    )
  ]


givenGameWithCode code =
  given (
    Subject.init (testInit 6 code)
      |> Subject.withUpdate testUpdate
  )


whenAGuessIsEvaluated guess =
  when "a guess is evaluated"
    [ Command.send <| Cmd.map GameMsg <| UseCases.evaluateGuess guess
    ]


expectGuessResult guessResult =
  Observer.observeModel .guessResult
    |> expect (equals <| Just guessResult)


type Msg
  = GameMsg Game.Msg
  | Notified Code GuessResult


type alias Model =
  { gameModel: Game.Model
  , guess: Maybe Code
  , guessResult: Maybe GuessResult
  }


testInit maxGuesses code =
  gameAdapters code
    |> Game.init { maxGuesses = maxGuesses }
    |> Tuple.mapFirst (\gameModel ->
      { gameModel = gameModel
      , guess = Nothing
      , guessResult = Nothing
      }  
    )
    |> Tuple.mapSecond (Cmd.map GameMsg)


testUpdate : Msg -> Model -> (Model, Cmd Msg)
testUpdate msg model =
  case msg of
    Notified guess result ->
      ( { model | guess = Just guess, guessResult = Just result }, Cmd.none )
    GameMsg gameMsg ->
      Game.update (gameAdapters []) gameMsg model.gameModel
        |> Tuple.mapFirst (\updated -> { model | gameModel = updated })


wrong : Int -> Int -> GuessResult
wrong colorsCorrect positionsCorrect =
  Clue.with colorsCorrect positionsCorrect
    |> Wrong


gameAdapters code =
  { codeGenerator = \tagger -> Command.fake <| tagger code
  , updateScoreStore = (\_ -> Cmd.none)
  , guessResultNotifier = (\guess guessResult -> Command.fake <| Notified guess guessResult)
  }


main =
  Runner.program
    [ evaluateGuessSpec
    ]