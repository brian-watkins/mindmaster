module UI.Vector.Arc exposing
  ( Arc
  , with
  , definition
  )


type alias Arc =
  { radius : Float
  , dx : Float
  , dy : Float
  , largeArcFlag : Int
  }


with : Float -> Float -> Arc
with radius extent =
  { radius = radius
  , dx = sin (radians extent) * radius
  , dy = radius - (cos (radians extent) * radius)
  , largeArcFlag = if extent > 0.5 then 1 else 0
  }


definition : Arc -> String
definition arc =
  "a "
    ++ String.fromFloat arc.radius
    ++ " "
    ++ String.fromFloat arc.radius
    ++ " 0 "
    ++ String.fromInt arc.largeArcFlag
    ++ " 1 "
    ++ String.fromFloat arc.dx
    ++ " "
    ++ String.fromFloat arc.dy


radians : Float -> Float
radians extent =
  (pi * 2) * extent
