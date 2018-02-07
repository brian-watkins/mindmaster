module UI.Vectors.Wedge exposing
  ( vector
  )

import Svg exposing (Svg, Attribute)
import Svg.Attributes as Attr


type alias ArcSegment =
  { dx : Float
  , dy : Float
  , largeArcFlag : Int
  }


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
    segment = arcSegment extent
  in
    "M 15 15 v -15 a 15 15 0 "
      ++ toString segment.largeArcFlag
      ++ " 1 "
      ++ toString segment.dx
      ++ " "
      ++ toString segment.dy
      ++ " Z"


radians : Float -> Float
radians extent =
  (pi * 2) * extent


arcSegment : Float -> ArcSegment
arcSegment extent =
  { dx = sin (radians extent) * 15
  , dy = 15 - (cos (radians extent) * 15)
  , largeArcFlag = if extent > 0.5 then 1 else 0
  }
