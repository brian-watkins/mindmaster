module Core.Types exposing
  ( GuessEvaluator
  , ViewDependencies
  , GameState(..)
  , GuessFeedback(..)
  , Color(..)
  , defaultColor
  , Clue
  , Code
  , Score
  , GameConfig
  , CodeGenerator
  , CoreAdapters
  , UpdateScoreStore
  )


type alias GameConfig =
  { maxGuesses : Int
  }


type alias CoreAdapters vmsg vmodel msg =
  { codeGenerator : CodeGenerator msg
  , viewUpdate : ViewUpdate vmsg msg vmodel
  , highScoresTagger : List Score -> vmsg
  , updateScoreStore : UpdateScoreStore msg
  }


type alias UpdateScoreStore msg =
  Maybe Score -> Cmd msg


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
  = Won Score
  | Lost Code
  | InProgress Int


type alias Score =
  Int


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
