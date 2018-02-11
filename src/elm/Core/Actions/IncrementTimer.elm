module Core.Actions.IncrementTimer exposing
  ( update
  )


type alias Model a =
  { a
  | gameTimer : Int
  }


update : Model a -> (Model a, Cmd msg)
update model =
  ( { model | gameTimer = model.gameTimer + 1 }
  , Cmd.none
  )
