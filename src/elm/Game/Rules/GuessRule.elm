module Game.Rules.GuessRule exposing
  ( apply
  )

import Game.Code as Code
import Game.Clue as Clue
import Util.Command as Command
import Game.Types exposing (..)


apply : Code -> Code -> GuessResult
apply code guess =
  if Code.equals code guess then
    Right
  else
    Wrong <|
      Clue.for code guess
