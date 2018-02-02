module Core.Actions.StartGame exposing
  ( update
  )

import Core.Types exposing (Code, GameState(..))


type alias Model a =
  { a
  | code : Code
  , gameState : GameState
  }

update : Code -> Model a -> (Model a, Cmd msg)
update code model =
  ( { model | code = code, gameState = InProgress }
  , Cmd.none
  )
