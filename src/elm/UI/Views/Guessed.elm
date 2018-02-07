module UI.Views.Guessed exposing
  ( view
  )

import UI.Types exposing (..)
import UI.Code as Code
import UI.Vectors.Circle as Circle
import Core.Types exposing (Code, Color(..))
import Html exposing (Html)
import Html.Attributes as Attr
import Svg
import Svg.Attributes as SvgAttr


view : Code -> Html Msg
view guess =
  Html.div [ Attr.class "guess" ] <|
    List.map guessElement guess


guessElement : Color -> Html Msg
guessElement element =
  Html.div [ Attr.class "guess-element" ]
  [ Svg.svg
    [ SvgAttr.viewBox "0 0 30 30" ]
    [ Circle.unit 15
      [ Attr.attribute "data-guess-element" ""
      , SvgAttr.class <| Code.colorToClass element
      ]
    ]
  ]
