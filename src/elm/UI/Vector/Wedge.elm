module UI.Vector.Wedge exposing
  ( vector
  )

import Svg exposing (Svg, Attribute)
import Svg.Attributes as Attr
import UI.Vector.Arc as Arc


vector : Float -> List (Attribute msg) -> Svg msg
vector extent attrs =
  Svg.path (
    List.append attrs
      [ Attr.d <| definition extent
      ]
  ) []


definition : Float -> String
definition extent =
  let
    arc = Arc.with 15 extent
  in
    "M 15 15 v -15 "
      ++ Arc.definition arc
      ++ " Z"
