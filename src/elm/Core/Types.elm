module Core.Types exposing
  ( GuessEvaluator
  , GameState(..)
  , GuessFeedback(..)
  , Color(..)
  , defaultColor
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
  (Code -> msg) -> Cmd msg


type GameState
  = Won
  | Lost Code
  | InProgress Int

type alias Code =
  List Color

type GuessFeedback
  = Wrong Clue
  | Correct

type alias Clue =
  { colors : Int
  , positions : Int
  }

defaultColor : Color
defaultColor =
  None


type Color
  = None
  | Red
  | Orange
  | Yellow
  | Green
  | Blue
