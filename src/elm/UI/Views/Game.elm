module UI.Views.Game exposing
  ( view
  )

import Html exposing (Html)
import Html.Attributes as Attr
import UI.Views.GuessHistory as GuessHistory
import UI.Views.GuessInput as GuessInput
import UI.Views.Outcome as Outcome
import UI.Views.Progress as Progress
import UI.Types exposing (..)
import Core.Types exposing (GameState(..))


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
