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
    Win ->
      Html.div []
      [ gameOverDisplay "You won!"
      , newGameButton
      ]

    Loss code ->
      Html.div []
      [ gameOverDisplay "You lost!"
      , Code.view "code" code
      , newGameButton
      ]


gameOverDisplay : String -> Html Msg
gameOverDisplay message =
  Html.div [ Attr.id "game-over-message" ]
    [ Html.text message ]


newGameButton : Html Msg
newGameButton =
  Html.div [ Attr.class "row" ]
  [ Html.div [ Attr.id "new-game", Events.onClick RestartGame ]
    [ Html.text "Play again!" ]
  ]
