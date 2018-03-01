module UI.View exposing
  ( with
  )

import Html exposing (Html)
import Html.Attributes as Attr
import UI.Types exposing (..)
import UI.View.Game as Game
import UI.View.Instructions as Instructions
import UI.View.Title as Title
import UI.View.HighScores as HighScores
import Game.Types exposing (GameState)


with : GameState -> Model -> Html Msg
with gameState model =
  Html.div []
  [ Title.view
  , Html.div [ Attr.class "row" ]
    [ Instructions.view
    , Game.view gameState model
    , HighScores.view model
    ]
  ]
