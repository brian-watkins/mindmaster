module Game.Subscriptions exposing
  ( for
  )

import Game exposing (..)
import Game.Types exposing (GameState(..))
import Time


for : Model -> Sub Msg
for model =
  case model.gameState of
    InProgress _ ->
      Time.every Time.second IncrementTimer
    _ ->
      Sub.none
