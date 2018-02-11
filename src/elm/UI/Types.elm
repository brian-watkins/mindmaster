module UI.Types exposing
  ( Msg(..)
  , Model
  , Outcome(..)
  , Guess
  , Validation(..)
  )

import Core.Types exposing (GuessFeedback, Code, Color)


type alias Guess =
  List (Maybe Color)


type Outcome
  = Win
  | Loss Code


type Msg
  = GuessInput Int Color
  | SubmitGuess
  | ReceivedFeedback Code GuessFeedback


type Validation
  = Valid
  | GuessIncomplete


type alias Model =
  { guess : Guess
  , history : List (Code, GuessFeedback)
  , codeLength : Int
  , validation : Validation
  , attempts : Int
  }
