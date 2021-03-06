module Game.Helpers exposing
  ( Msg(..)
  , Model
  , testSubject
  , testSubscriptions
  , expectGameModel
  , expectStoredScore
  , expectGameState
  , evaluateGuess
  , startNewGame
  )

import Spec exposing (..)
import Spec.Setup as Setup
import Spec.Observer as Observer
import Spec.Command as Command
import Spec.Extra exposing (equals)
import Game
import Game.Action as Game
import Game.UseCases as UseCases
import Game.Subscriptions
import Game.Types exposing (..)
import Runner


type Msg
  = GameMsg Game.Msg
  | Notified Code GuessResult
  | StoreScore (Maybe Score)


type alias Model =
  { gameModel: Game.Model
  , guess: Maybe Code
  , guessResult: Maybe GuessResult
  , storedScore: Maybe Score
  }


testSubject maxGuesses code =
  Setup.init (testInit maxGuesses code)
    |> Setup.withUpdate testUpdate


testInit maxGuesses code =
  gameAdapters code
    |> Game.init { maxGuesses = maxGuesses }
    |> Tuple.mapFirst (\gameModel ->
      { gameModel = gameModel
      , guess = Nothing
      , guessResult = Nothing
      , storedScore = Nothing
      }  
    )


testUpdate : Msg -> Model -> (Model, Cmd Msg)
testUpdate msg model =
  case msg of
    Notified guess result ->
      ( { model | guess = Just guess, guessResult = Just result }, Cmd.none )
    StoreScore maybeScore ->
      ( { model | storedScore = maybeScore }, Cmd.none )
    GameMsg gameMsg ->
      Game.update (gameAdapters []) gameMsg model.gameModel
        |> Tuple.mapFirst (\updated -> { model | gameModel = updated })


expectGameModel claim =
  Observer.observeModel .gameModel
    |> expect claim


evaluateGuess guess =
  UseCases.evaluateGuess guess
    |> Cmd.map GameMsg
    |> Command.send


startNewGame code =
  UseCases.startGame (gameAdapters code)
    |> Command.send


expectGameState gameState =
  expectGameModel <| \model ->
    UseCases.gameState model
      |> equals gameState


gameAdapters code =
  { codeGenerator = \tagger -> Command.fake <| GameMsg <| tagger code
  , updateScoreStore = (\maybeScore -> Command.fake <| StoreScore maybeScore)
  , guessResultNotifier = (\guess guessResult -> Command.fake <| Notified guess guessResult)
  }


testSubscriptions : Model -> Sub Msg
testSubscriptions model =
  Game.Subscriptions.for model.gameModel
    |> Sub.map GameMsg


expectStoredScore score =
  Observer.observeModel .storedScore
    |> expect (equals <| Just score)
