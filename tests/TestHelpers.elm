module TestHelpers exposing
  ( foldStates
  )

import Elmer exposing (TestState, Matcher)
import Expect exposing (Expectation)


foldStates : TestState model msg -> List (TestState model msg -> TestState model msg) -> TestState model msg
foldStates initialState =
  List.foldl (<|) initialState
