module Game.Action.IncrementTimer exposing
  ( update
  )


type alias Model a =
  { a
  | timer : Int
  }


update : Model a -> (Model a, Cmd msg)
update model =
  ( { model | timer = model.timer + 1 }
  , Cmd.none
  )
