module UI.Actions.RecordGuess exposing
  ( update
  )

import Core.Types exposing (Code, GuessResult)


type alias Model a =
  { a
  | history : List (Code, GuessResult)
  }


update : Code -> GuessResult -> Model a -> ( Model a, Cmd msg )
update guess guessResult model =
  ( recordGuess model (guess, guessResult)
  , Cmd.none
  )


recordGuess : Model a -> (Code, GuessResult) -> Model a
recordGuess model guessRecord =
  { model | history = guessRecord :: model.history }
