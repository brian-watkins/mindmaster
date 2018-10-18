module Game.TestHelpers exposing
  ( timeSpy
  , updateScoreStoreSpy
  , testInit
  , testModel
  , gameAdapters
  , gameAdaptersWithHighScore
  , testUpdateWithHighScores
  , testUpdate
  )

import Game.Types exposing (..)
import Game.Fakes.FakeCodeGenerator as FakeCodeGenerator
import Elmer.Spy as Spy exposing (Spy, andCallFake)
import Elmer.Command as Command
import Game.Action as Game
import Time
import Elmer.Subscription as Subscription


timeSpy : Spy
timeSpy =
  Spy.create "time-spy" (\_ -> Time.every)
    |> andCallFake (\_ tagger ->
      Subscription.fake "time-sub" tagger
    )


updateScoreStoreSpy : Spy
updateScoreStoreSpy =
  Spy.createWith "update-score-store-spy" <|
    \_ -> Cmd.none


testInit maxGuesses code =
  gameAdapters code
    |> Game.init { maxGuesses = maxGuesses }


testModel =
  testInit 0 []
    |> Tuple.first


gameAdapters code =
  { codeGenerator = FakeCodeGenerator.with code
  , updateScoreStore = (\_ -> Cmd.none)
  , guessResultNotifier = (\guess guessResult -> Cmd.none)
  }


gameAdaptersWithHighScore code =
  { codeGenerator = FakeCodeGenerator.with code
  , updateScoreStore = Spy.callable "update-score-store-spy"
  , guessResultNotifier = (\guess guessResult -> Cmd.none)
  }


testUpdateWithHighScores =
  let
    adapters = gameAdapters []
  in
    { adapters | updateScoreStore = Spy.callable "update-score-store-spy" }
      |> Game.update


testUpdate =
  gameAdapters []
    |> Game.update
