module Core.Actions.UpdateScoreStore exposing
  ( update
  )

import Core.Types exposing (UpdateScoreStore, GameState(..))


type alias Model a =
  { a
  | gameState : GameState
  }


update : UpdateScoreStore msg -> Model a -> (Model a, Cmd msg)
update updateScoreStore model =
  case model.gameState of
    Won score ->
      ( model, updateScoreStore <| Just score)
    _ ->
      ( model, updateScoreStore Nothing )
