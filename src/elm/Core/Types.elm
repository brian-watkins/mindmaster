module Core.Types exposing
  ( GuessFeedback(..)
  , Color(..)
  , Clue
  )

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
