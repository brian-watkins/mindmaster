module UI.Views.Code exposing
  ( view
  )

import UI.Types exposing (..)
import UI.Color as Color
import UI.Vectors.Circle as Circle
import Core.Types exposing (Code, Color)
import Html exposing (Html)
import Html.Attributes as Attr
import Svg
import Svg.Attributes as SvgAttr


view : String -> Code -> Html Msg
view class code =
  Html.div [ Attr.class class ] <|
    List.map (codeElement class) code


codeElement : String -> Color -> Html Msg
codeElement class element =
  Html.div [ Attr.class <| class ++ "-element" ]
  [ Svg.svg
    [ SvgAttr.viewBox "0 0 30 30" ]
    [ Circle.unit 15
      [ Attr.attribute ("data-" ++ class ++ "-element") ""
      , SvgAttr.class <| Color.toClass element
      ]
    ]
  ]
