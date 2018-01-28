module Core.Code exposing
  ( colors
  , generate
  , equals
  , correctColors
  , correctPositions
  )

import Core.Types exposing (..)


colors : List Color
colors =
  [ Red
  , Orange
  , Yellow
  , Green
  , Blue
  ]


type alias CodeGenerator a =
  Color -> Code -> Int -> (Code -> a) -> Cmd a


generate : (Code -> a) -> CodeGenerator a -> Cmd a
generate tagger generator =
  generator Blue colors 5 tagger


equals : Code -> Code -> Bool
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


correctColors : Code -> Code -> Int
correctColors =
  findCorrectColors 0


findCorrectColors : Int -> Code -> Code -> Int
findCorrectColors found code guess =
  case guess of
    [] ->
      found
    x :: xs ->
      if List.member x code then
        let
          filtered =
            removeFirst 0 x code
        in
          findCorrectColors (found + 1) filtered xs
      else
        findCorrectColors found code xs


removeFirst : Int -> a -> List a -> List a
removeFirst offset item items =
  case List.drop offset items of
    [] ->
      items
    x :: xs ->
      if x == item then
        List.append (List.take offset items) xs
      else
        removeFirst (offset + 1) item items



correctPositions : Code -> Code -> Int
correctPositions =
  findCorrectPositions 0


findCorrectPositions : Int -> Code -> Code -> Int
findCorrectPositions found code guess =
  case code of
    [] ->
      found
    x :: xs ->
      case guess of
        [] ->
          found
        g :: gs ->
          if x == g then
            findCorrectPositions (found + 1) xs gs
          else
            findCorrectPositions found xs gs
