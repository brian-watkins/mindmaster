module UI.Types exposing
  ( Msg(..)
  , Model
  , Outcome(..)
  , Guess
  , Validation(..)
  )

import Core.Types exposing (GuessEvaluator, GuessFeedback, Code, Color, Score)


type alias Guess =
  List (Maybe Color)


type Outcome
  = Win Int
  | Loss Code


type Msg
  = GuessInput Int Color
  | SubmitGuess
  | ReceivedFeedback Code GuessFeedback
  | RestartGame
  | HighScores (List Score)


type Validation
  = Valid
  | GuessIncomplete


type alias Model =
  { guess : Guess
  , history : List (Code, GuessFeedback)
  , codeLength : Int
  , validation : Validation
  , attempts : Int
  , colors : List Color
  , highScores : List Score
  }
