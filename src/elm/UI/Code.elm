module UI.Code exposing
  ( fromString
  )

import Core.Types exposing (Color(..), Code)

fromString : String -> Code
fromString guess =
  asCode guess []

asCode : String -> Code -> Code
asCode guess code =
  case String.uncons guess of
    Just (c, str) ->
      [ toColor c ]
        |> List.append code
        |> asCode str
    Nothing ->
      code

toColor : Char -> Color
toColor c =
  case c of
    'r' -> Red
    'o' -> Orange
    'y' -> Yellow
    'g' -> Green
    _ -> Blue
