module UI.View.Outcome exposing
  ( view
  )

import UI.Types exposing (..)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import UI.View.Code as Code
import Svg
import Svg.Attributes as SvgAttr
import UI.Vector.Circle as Circle
import Game.Types exposing (Code, Color)

view : Outcome -> Html Msg
view outcome =
  case outcome of
    Win score ->
      Html.div []
      [ outcomMessage "You won!"
      , finalScore score
      , newGameButton
      ]

    Loss code ->
      Html.div []
      [ outcomMessage "You lost!"
      , secretCode code
      , newGameButton
      ]


outcomMessage : String -> Html Msg
outcomMessage message =
  Html.div [ Attr.id "game-over-message" ]
    [ Html.text message ]


finalScore : Int -> Html Msg
finalScore score =
  Html.div [ Attr.id "final-score" ]
    [ Html.text <| "Final Score: " ++ String.fromInt score ]


newGameButton : Html Msg
newGameButton =
  Html.div [ Attr.class "row" ]
  [ Html.div [ Attr.id "new-game", Events.onClick RestartGame ]
    [ Html.text "Play again!" ]
  ]


secretCode : Code -> Html Msg
secretCode =
  Code.view "code"
