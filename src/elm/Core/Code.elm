module Core.Code exposing
  ( none
  , colors
  , generate
  , equals
  , correctColors
  , correctPositions
  )

import Core.Types exposing (..)


none : Code
none =
  []


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
correctColors code guess =
  case guess of
    [] ->
      0
    x :: xs ->
      if List.member x code then
        let
          filtered = removeFirst x code
        in
          1 +
            correctColors filtered xs
      else
        correctColors code xs


removeFirst : a -> List a -> List a
removeFirst item items =
  case items of
    [] ->
      []
    x :: xs ->
      if x == item then
        xs
      else
        x ::
          removeFirst item xs


correctPositions : Code -> Code -> Int
correctPositions code guess =
  case code of
    [] ->
      0
    x :: xs ->
      case guess of
        [] ->
          0
        g :: gs ->
          if x == g then
            1 +
              correctPositions xs gs
          else
            correctPositions xs gs
