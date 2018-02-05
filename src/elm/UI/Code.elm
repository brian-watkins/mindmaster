module UI.Code exposing
  ( toString
  , colorToClass
  )

import Core.Types exposing (Color(..), Code)


colorToClass : Color -> String
colorToClass c =
  case c of
    Red -> "red"
    Orange -> "orange"
    Yellow -> "yellow"
    Green -> "green"
    Blue -> "blue"


toString : Code -> String
toString code =
  List.map colorToString code
    |> String.fromList


colorToString : Color -> Char
colorToString c =
  case c of
    Red -> 'r'
    Orange -> 'o'
    Yellow -> 'y'
    Green -> 'g'
    Blue -> 'b'
