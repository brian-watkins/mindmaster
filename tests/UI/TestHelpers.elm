module UI.TestHelpers exposing
  ( viewDependencies
  , testUpdate
  , testView
  )

import Game.Types exposing (..)
import UI.Types exposing (..)
import UI.Action
import UI.View


testUpdate : UseCases msg -> Msg -> Model -> (Model, Cmd msg)
testUpdate =
  UI.Action.update

testView =
  UI.View.for

viewDependencies =
  { guessEvaluator = \_ -> Cmd.none
  , restartGame = Cmd.none
  }
