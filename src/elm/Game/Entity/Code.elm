module Game.Entity.Code exposing
  ( none
  , equals
  , difference
  )

import Game.Types exposing (..)
import Game.Entity.Clue as Clue


none : Code
none =
  []


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


difference : Code -> Code -> Clue
difference code guess =
  Clue.with
    (correctColors code guess)
    (correctPositions code guess)


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
