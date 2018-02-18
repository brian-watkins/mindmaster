module UI.TestHelpers exposing
  ( viewDependencies
  , testUpdate
  )

import Core.Types exposing (..)
import UI.Types exposing (..)
import UI


testUpdate : ViewDependencies Msg msg -> Msg -> Model -> (Model, Cmd msg)
testUpdate =
  UI.update


viewDependencies =
  { guessEvaluator = \_ _ -> Cmd.none
  , restartGameCommand = Cmd.none
  }
