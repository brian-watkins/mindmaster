module UI.Types exposing
  ( Msg(..)
  , Model
  , Outcome(..)
  , Guess
  , Validation(..)
  )

import Game.Types exposing (GuessEvaluator, GuessResult, Code, Color, Score)


type alias Guess =
  List (Maybe Color)


type Outcome
  = Win Int
  | Loss Code


type Msg
  = GuessInput Int Color
  | SubmitGuess
  | ReceivedFeedback Code GuessResult
  | RestartGame
  | HighScores (List Score)


type Validation
  = Valid
  | GuessIncomplete


type alias Model =
  { guess : Guess
  , history : List (Code, GuessResult)
  , codeLength : Int
  , validation : Validation
  , attempts : Int
  , colors : List Color
  , highScores : List Score
  }
