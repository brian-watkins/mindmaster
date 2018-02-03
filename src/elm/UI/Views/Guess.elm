module UI.Views.Guess exposing
  ( view
  )

import UI.Types exposing (..)
import UI.Code as Code
import Core.Types exposing (Color(..))
import Html exposing (Html)
import Html.Attributes as Attr
import Svg
import Svg.Attributes as SvgAttr


view : String -> Html Msg
view guessString =
  let
    guess = Code.fromString guessString
  in
    Html.div [ Attr.class "guess" ] <|
      List.map guessElement guess


guessElement : Color -> Html Msg
guessElement element =
  Html.div [ Attr.class "guess-element" ]
  [ Svg.svg
    [ SvgAttr.viewBox "0 0 30 30" ]
    [ Svg.circle
      [ SvgAttr.cx "15"
      , SvgAttr.cy "15"
      , SvgAttr.r "15"
      , Attr.attribute "data-guess-element" <| colorToClass element
      , SvgAttr.class <| colorToClass element
      ] []
    ]
  ]

colorToClass : Color -> String
colorToClass c =
  case c of
    Red -> "red"
    Orange -> "orange"
    Yellow -> "yellow"
    Green -> "green"
    Blue -> "blue"
