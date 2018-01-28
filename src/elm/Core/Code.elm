module Core.Code exposing
  ( colors
  , generate
  , equals
  , correctColors
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


correctColors : List Color -> List Color -> Int
correctColors =
  findCorrectColors 0


findCorrectColors : Int -> List Color -> List Color -> Int
findCorrectColors found code guess =
  case guess of
    [] ->
      found
    x :: xs ->
      if List.member x code then
        findCorrectColors (found + 1) code xs
      else
        findCorrectColors found code xs
