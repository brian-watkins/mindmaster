module Core.Types exposing
  ( GuessEvaluator
  , ViewDependencies
  , GameState(..)
  , GuessFeedback(..)
  , Color(..)
  , defaultColor
  , Clue
  , Code
  , GameConfig
  , CodeGenerator
  , CoreAdapters
  )


type alias GameConfig =
  { maxGuesses : Int
  }


type alias CoreAdapters vmsg vmodel msg =
  { codeGenerator : CodeGenerator msg
  , viewUpdate : ViewUpdate vmsg msg vmodel
  }


type alias ViewUpdate vmsg msg vmodel =
  ViewDependencies vmsg msg -> vmsg -> vmodel -> (vmodel, Cmd msg)

type alias ViewDependencies vmsg msg =
  { guessEvaluator : GuessEvaluator vmsg msg
  , restartGameCommand : Cmd msg
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
