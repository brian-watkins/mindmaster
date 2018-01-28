module Core.Types exposing
  ( GuessFeedback(..)
  , Color(..)
  , Clue
  , Code
  )

type alias Code =
  List Color

type GuessFeedback
  = Wrong Clue
  | Correct

type alias Clue =
  { colors : Int
  , positions : Int
  }

type Color
  = Red
  | Orange
  | Yellow
  | Green
  | Blue
