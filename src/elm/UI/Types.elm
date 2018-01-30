module UI.Types exposing
  ( Msg(..)
  , Model
  )

import Core.Types exposing (GuessFeedback)


type Msg
  = GuessInput String
  | SubmitGuess
  | ReceivedFeedback String GuessFeedback


type alias Model =
  { guess : Maybe String
  , history : List (String, GuessFeedback)
  }
