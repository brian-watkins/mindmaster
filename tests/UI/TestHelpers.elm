module UI.TestHelpers exposing
  ( viewDependencies
  , testUpdate
  )

import Game.Types exposing (..)
import UI.Types exposing (..)
import UI


testUpdate : UseCases msg -> Msg -> Model -> (Model, Cmd msg)
testUpdate =
  UI.update


viewDependencies =
  { guessEvaluator = \_ -> Cmd.none
  , restartGame = Cmd.none
  }
