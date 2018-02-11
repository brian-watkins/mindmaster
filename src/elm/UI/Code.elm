module UI.Code exposing
  ( toString
  , colorToClass
  )

import Core.Types exposing (Color(..), Code)


colorToClass : Color -> String
colorToClass color =
  Basics.toString color
    |> String.toLower


toString : Code -> String
toString code =
  List.map colorToString code
    |> String.fromList


colorToString : Color -> Char
colorToString c =
  case c of
    None -> ' '
    Red -> 'r'
    Orange -> 'o'
    Yellow -> 'y'
    Green -> 'g'
    Blue -> 'b'
