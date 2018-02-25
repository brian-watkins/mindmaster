module UI exposing
  ( defaultModel
  , highScoresTagger
  , guessResultTagger
  )

import Game.Types exposing (..)
import UI.Types exposing (..)
import UI.Entity.Guess as Guess


type alias UIConfig =
  { codeLength : Int
  , colors : List Color
  }


defaultModel : UIConfig -> Model
defaultModel config =
  { guess = Guess.empty config.codeLength
  , history = []
  , codeLength = config.codeLength
  , validation = Valid
  , attempts = 0
  , colors = config.colors
  , highScores = []
  }


highScoresTagger : List Score -> Msg
highScoresTagger =
  HighScores


guessResultTagger : Code -> GuessResult -> Msg
guessResultTagger =
  ReceivedFeedback
