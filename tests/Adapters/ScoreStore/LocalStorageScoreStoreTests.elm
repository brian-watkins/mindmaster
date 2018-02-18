module Adapters.ScoreStore.LocalStorageScoreStoreTests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Elmer exposing (exactly)
import Elmer.Headless as Headless
import Elmer.Spy as Spy exposing (Spy, andCallFake)
import Elmer.Spy.Matchers exposing (wasCalled, wasCalledWith, typedArg)
import Elmer.Platform.Subscription as Subscription
import ScoreStore.LocalStorageScoreStore as ScoreStore
import Core.Types exposing (Score)


requestScoresTests : Test
requestScoresTests =
  describe "when no score is passed" <|
  let
    testState =
      Headless.givenCommand (\_ -> ScoreStore.execute Nothing)
        |> Spy.use [ requestScoresSpy, getScoresSpy ]
        |> Subscription.with (\_ -> (\_ -> ScoreStore.subscriptions ScoreTagger))
        |> Subscription.send "scores-sub" [ 190, 218, 332 ]
  in
    [ test "it requests the scores" <|
      \() ->
        testState
          |> Spy.expect "request-scores-spy" (wasCalled 1)
    , test "it tags the scores" <|
      \() ->
        testState
          |> Headless.expectMessages (exactly 1 <|
              Expect.equal (ScoreTagger [ 190, 218, 332 ])
          )
    ]


storeScoresTests : Test
storeScoresTests =
  describe "when a score is stored" <|
  let
    testState =
      Headless.givenCommand (\_ -> ScoreStore.execute <| Just 217)
        |> Spy.use [ requestScoresSpy, getScoresSpy ]
        |> Subscription.with (\_ -> (\_ -> ScoreStore.subscriptions ScoreTagger))
        |> Subscription.send "scores-sub" [ 190, 218, 332, 217 ]
  in
    [ test "it requests the scores" <|
      \() ->
        testState
          |> Spy.expect "request-scores-spy" (
            wasCalledWith [ typedArg <| Just 217 ]
          )
    , test "it tags the scores" <|
      \() ->
        testState
          |> Headless.expectMessages (exactly 1 <|
              Expect.equal (ScoreTagger [ 190, 218, 332, 217 ])
          )
    ]


type TestMsg
  = ScoreTagger (List Score)


requestScoresSpy : Spy
requestScoresSpy =
  Spy.create "request-scores-spy" (\_ -> ScoreStore.requestScores)
    |> andCallFake (\_ ->
      Cmd.none
    )


getScoresSpy : Spy
getScoresSpy =
  Spy.create "scores-spy" (\_ -> ScoreStore.scores)
    |> andCallFake (\tagger ->
      Subscription.fake "scores-sub" tagger
    )
