module Core.TestHelpers exposing
  ( testUpdate
  , coreAdapters
  , updateScoreStoreSpy
  )

import Core.Types exposing (..)
import Core
import Core.Fakes.FakeUI as FakeUI
import Core.Fakes.FakeCodeGenerator as FakeCodeGenerator
import Elmer.Spy as Spy exposing (Spy)
import Elmer.Platform.Command as Command


coreAdapters code =
  { viewUpdate = FakeUI.update
  , highScoresTagger = FakeUI.UpdateHighScores
  , codeGenerator = FakeCodeGenerator.with code
  , updateScoreStore = (\_ -> Cmd.none)
  }

testUpdate code =
  coreAdapters code
    |> Core.update


updateScoreStoreSpy : List Score -> (List Score -> msg) -> Spy
updateScoreStoreSpy scores tagger =
  Spy.createWith "update-score-store-spy" <|
    \_ ->
      Command.fake <| tagger scores
