module Game.Action.StartGame exposing
  ( update
  )

import Game.Types exposing (Code, GameState(..))


type alias Model a =
  { a
  | code : Code
  , gameState : GameState
  , guesses : Int
  , maxGuesses : Int
  }


update : Code -> Model a -> (Model a, Cmd msg)
update code model =
  ( { model
    | code = code
    , guesses = 0
    , gameState = InProgress model.maxGuesses
    }
  , Cmd.none
  )
