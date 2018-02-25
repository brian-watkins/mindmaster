module UI.View.Game exposing
  ( view
  )

import Html exposing (Html)
import Html.Attributes as Attr
import UI.View.GuessHistory as GuessHistory
import UI.View.GuessInput as GuessInput
import UI.View.Outcome as Outcome
import UI.View.Progress as Progress
import UI.Types exposing (..)
import Game.Types exposing (GameState(..))


view : GameState -> Model -> Html Msg
view gameState model =
  case gameState of
    InProgress remainingGuesses ->
      Html.div [ Attr.id "game-board" ]
      [ GuessInput.view model
      , Progress.view remainingGuesses
      , GuessHistory.view model
      ]
    Won score ->
      Html.div [ Attr.id "game-board" ]
      [ Outcome.view <| Win score
      , GuessHistory.view model
      ]
    Lost code ->
      Html.div [ Attr.id "game-board" ]
      [ Outcome.view <| Loss code
      , GuessHistory.view model
      ]
