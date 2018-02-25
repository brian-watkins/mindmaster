module Game.Rule.GuessRule exposing
  ( apply
  )

import Game.Entity.Code as Code
import Game.Entity.Clue as Clue
import Util.Command as Command
import Game.Types exposing (..)


apply : Code -> Code -> GuessResult
apply code guess =
  if Code.equals code guess then
    Right
  else
    Wrong <|
      Clue.for code guess
