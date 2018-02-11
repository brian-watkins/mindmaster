module UI.Actions.RecordGuess exposing
  ( update
  )

import Core.Types exposing (Code, GuessFeedback)


type alias Model a =
  { a
  | history : List (Code, GuessFeedback)
  }


update : Code -> GuessFeedback -> Model a -> ( Model a, Cmd msg )
update guess feedback model =
  ( recordGuess model (guess, feedback)
  , Cmd.none
  )


recordGuess : Model a -> (Code, GuessFeedback) -> Model a
recordGuess model guessRecord =
  { model | history = guessRecord :: model.history }
