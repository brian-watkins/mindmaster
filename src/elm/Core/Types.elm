module Core.Types exposing
  ( GuessEvaluator
  , GameState(..)
  , GuessFeedback(..)
  , Color(..)
  , Clue
  , Code
  )


type alias GuessEvaluator vmsg msg =
  (GuessFeedback -> vmsg) -> Code -> Cmd msg

type GameState
  = Won
  | InProgress

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
