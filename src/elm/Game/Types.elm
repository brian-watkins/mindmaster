module Game.Types exposing
  ( GuessEvaluator
  , UseCases
  , GameState(..)
  , GuessResult(..)
  , Color(..)
  , defaultColor
  , Clue
  , Code
  , Score
  , GameConfig
  , CodeGenerator
  , UpdateScoreStore
  )


type alias GameConfig =
  { maxGuesses : Int
  }


type alias UpdateScoreStore msg =
  Maybe Score -> Cmd msg


type alias UseCases msg =
  { guessEvaluator : GuessEvaluator msg
  , restartGame : Cmd msg
  }


type alias GuessEvaluator msg =
  Code -> Cmd msg


type alias CodeGenerator msg =
  (Code -> msg) -> Cmd msg


type GameState
  = Won Score
  | Lost Code
  | InProgress Int


type alias Score =
  Int


type alias Code =
  List Color


type GuessResult
  = Wrong Clue
  | Right


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
