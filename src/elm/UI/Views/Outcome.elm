module UI.Views.Outcome exposing
  ( view
  )

import UI.Types exposing (..)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import UI.Views.Code as Code
import Svg
import Svg.Attributes as SvgAttr
import UI.Vectors.Circle as Circle
import Core.Types exposing (Code, Color)

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
    [ Html.text <| "Final Score: " ++ toString score ]


newGameButton : Html Msg
newGameButton =
  Html.div [ Attr.class "row" ]
  [ Html.div [ Attr.id "new-game", Events.onClick RestartGame ]
    [ Html.text "Play again!" ]
  ]


secretCode : Code -> Html Msg
secretCode =
  Code.view "code"
