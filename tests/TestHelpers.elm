module TestHelpers exposing
  ( expectAll
  , foldStates
  )

import Elmer exposing (TestState, Matcher, (<&&>))
import Expect exposing (Expectation)


expectAll : List (Matcher a) -> Matcher a
expectAll =
  List.foldl (<&&>) (\_ -> Expect.pass)


foldStates : TestState model msg -> List (TestState model msg -> TestState model msg) -> TestState model msg
foldStates initialState =
  List.foldl (<|) initialState
