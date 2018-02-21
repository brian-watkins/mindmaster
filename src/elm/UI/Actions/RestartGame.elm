module UI.Actions.RestartGame exposing
  ( update
  )

import Core.Types exposing (Code, GuessResult)


type alias Model a =
  { a
  | history : List (Code, GuessResult)
  }

update : Cmd msg -> Model a -> ( Model a, Cmd msg )
update restartGameCommand model =
  ( { model | history = [] }
  , restartGameCommand
  )
