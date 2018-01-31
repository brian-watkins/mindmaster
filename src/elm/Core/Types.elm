module Core.Types exposing
  ( GuessEvaluator
  , GameState(..)
  , GuessFeedback(..)
  , Color(..)
  , Clue
  , Code
  , GameConfig
  , CodeGenerator
  )


type alias GameConfig msg =
  { codeGenerator : CodeGenerator msg
  , maxGuesses : Int
  }

type alias GuessEvaluator vmsg msg =
  (GuessFeedback -> vmsg) -> Code -> Cmd msg

type alias CodeGenerator msg =
  Color -> Code -> Int -> (Code -> msg) -> Cmd msg

type GameState
  = Won
  | Lost Code
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
