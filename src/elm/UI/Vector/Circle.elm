module UI.Vector.Circle exposing
  ( unit
  , vector
  )

import Svg exposing (Svg, Attribute)
import Svg.Attributes as Attr


type alias Model =
  { x : Float
  , y : Float
  , radius : Float
  }


vector : Model -> List (Attribute msg) -> Svg msg
vector model attrs =
  Svg.circle (
    List.append attrs
      [ Attr.cx <| String.fromFloat model.x
      , Attr.cy <| String.fromFloat model.y
      , Attr.r <| String.fromFloat model.radius
      ]
  ) []


unit : Float -> List (Attribute msg) -> Svg msg
unit radius attrs =
  vector { x = 15, y = 15, radius = radius }
    attrs
