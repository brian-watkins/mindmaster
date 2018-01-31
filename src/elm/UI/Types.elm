module UI.Types exposing
  ( Msg(..)
  , Model
  , Outcome(..)
  )

import Core.Types exposing (GuessFeedback, Code)


type Outcome
  = Win
  | Loss Code

type Msg
  = GuessInput String
  | SubmitGuess
  | ReceivedFeedback String GuessFeedback


type alias Model =
  { guess : Maybe String
  , history : List (String, GuessFeedback)
  }
