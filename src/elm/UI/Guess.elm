module UI.Guess exposing
  ( none
  , with
  , toCode
  , colorAt
  )

import Core.Types exposing (Code, Color(..))
import UI.Types exposing (Guess)


none : Guess
none =
  [ Nothing, Nothing, Nothing, Nothing, Nothing ]


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
  List.map (Maybe.withDefault Blue)


colorAt : Int -> Guess -> Maybe Color
colorAt position guess =
  List.drop position guess
    |> List.head
    |> Maybe.withDefault Nothing
