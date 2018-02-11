module UI.Vectors.Attribute exposing
  ( classList
  )

import Svg exposing (Attribute)
import Svg.Attributes as Attr


classList : List (String, Bool) -> Attribute msg
classList classes =
  List.filter Tuple.second classes
    |> List.map Tuple.first
    |> String.join " "
    |> Attr.class
