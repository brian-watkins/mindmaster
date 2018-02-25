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
    ++ toString arc.radius
    ++ " "
    ++ toString arc.radius
    ++ " 0 "
    ++ toString arc.largeArcFlag
    ++ " 1 "
    ++ toString arc.dx
    ++ " "
    ++ toString arc.dy


radians : Float -> Float
radians extent =
  (pi * 2) * extent
