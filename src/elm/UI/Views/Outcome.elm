module UI.Views.Outcome exposing
  ( view
  )

import UI.Types exposing (..)
import Html exposing (Html)
import Html.Attributes as Attr
import UI.Code as Code


view : Outcome -> Html Msg
view outcome =
  case outcome of
    Win ->
      "You win!"
        |> gameOverDisplay
    Loss code ->
      "You lost! The code is: " ++ Code.toString code
        |> gameOverDisplay


gameOverDisplay : String -> Html Msg
gameOverDisplay message =
  Html.div [ Attr.id "game-over-message" ]
    [ Html.text message ]
