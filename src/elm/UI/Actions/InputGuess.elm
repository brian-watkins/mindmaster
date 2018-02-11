module UI.Actions.InputGuess exposing
  ( update
  )

import Core.Types exposing (Color)
import UI.Guess as Guess
import UI.Types exposing (Guess)


type alias Model a =
  { a
  | guess : Guess
  }


update : Int -> Color -> Model a -> ( Model a, Cmd msg )
update position guessColor model =
  ( { model | guess = Guess.with position guessColor model.guess }
  , Cmd.none
  )
