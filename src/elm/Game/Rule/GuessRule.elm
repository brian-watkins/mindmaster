module Game.Rule.GuessRule exposing
  ( apply
  )

import Game.Entity.Code as Code
import Util.Command as Command
import Game.Types exposing (..)


apply : Code -> Code -> GuessResult
apply code guess =
  if Code.equals code guess then
    Right
  else
    Wrong <|
      Code.difference code guess
