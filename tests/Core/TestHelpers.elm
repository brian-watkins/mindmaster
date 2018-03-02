module Core.TestHelpers exposing
  ( testUpdate
  , testModel
  , testModelWithMax
  , viewSpy
  , testView
  , testConfig
  , coreAdapters
  , updateScoreStoreSpy
  , testInit
  , testInitWithMax
  )

import Game.Types exposing (..)
import Core.Fakes.FakeUI as FakeUI
import Core.Fakes.FakeCodeGenerator as FakeCodeGenerator
import Elmer.Spy as Spy exposing (Spy)
import Elmer.Platform.Command as Command
import Configuration.Bus as Bus


coreAdapters code =
  { updateUI = FakeUI.update
  , codeGenerator = FakeCodeGenerator.with code
  , updateScoreStore = (\_ -> Cmd.none)
  , guessResultTagger = FakeUI.HandleFeedback
  }


testModel =
  testModelWithMax 18


testModelWithMax maxGuesses =
  FakeUI.defaultModel []
    |> Bus.init (testConfig 18) (coreAdapters [])
    |> Tuple.first


viewSpy : Spy
viewSpy =
  Spy.create "view-spy" (\_ -> FakeUI.view)


testView =
  Bus.view FakeUI.view


testUpdate code =
  coreAdapters code
    |> Bus.update


testConfig maxGuesses =
  { maxGuesses = maxGuesses
  }


updateScoreStoreSpy : Spy
updateScoreStoreSpy =
  Spy.createWith "update-score-store-spy" <|
    \_ ->
      Cmd.none


testInit guesses code =
  FakeUI.defaultModel guesses
    |> Bus.init (testConfig 18) (coreAdapters code)


testInitWithMax maxGuesses guesses code =
  FakeUI.defaultModel guesses
    |> Bus.init (testConfig maxGuesses) (coreAdapters code)
