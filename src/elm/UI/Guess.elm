module UI.Guess exposing
  ( empty
  , with
  , toCode
  , colorAt
  , lengthSelected
  )

import Core.Types exposing (Code, Color, defaultColor)
import UI.Types exposing (Guess)


empty : Int -> Guess
empty codeLength =
  List.repeat codeLength Nothing


with : Int -> Color -> Guess -> Guess
with position element guess =
  let
    before =
      List.take position guess
    after =
      List.drop (position + 1) guess
  in
    (Just element) :: after
      |> List.append before


toCode : Guess -> Code
toCode =
  List.map (Maybe.withDefault defaultColor)


colorAt : Int -> Guess -> Maybe Color
colorAt position guess =
  List.drop position guess
    |> List.head
    |> Maybe.withDefault Nothing


lengthSelected : Guess -> Int
lengthSelected guess =
   List.filterMap identity guess
    |> List.length
