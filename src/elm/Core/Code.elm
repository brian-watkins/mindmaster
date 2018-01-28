module Core.Code exposing
  ( colors
  , generate
  , equals
  )

import Core.Types exposing (Color(..))

colors : List Color
colors =
  [ Red
  , Orange
  , Yellow
  , Green
  , Blue
  ]

type alias CodeGenerator a =
  Color -> List Color -> Int -> (List Color -> a) -> Cmd a

generate : (List Color -> a) -> CodeGenerator a -> Cmd a
generate tagger generator =
  generator Blue colors 5 tagger


equals : List Color -> List Color -> Bool
equals expected actual =
  case expected of
    [] ->
      List.isEmpty actual
    x :: xl ->
      case List.head actual of
        Just h ->
          if x == h then
            equals xl (List.drop 1 actual)
          else
            False
        Nothing ->
          False
