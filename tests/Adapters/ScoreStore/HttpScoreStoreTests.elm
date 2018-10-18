module Adapters.ScoreStore.HttpScoreStoreTests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Elmer exposing (exactly)
import Elmer.Command as Command
import Elmer.Http as Http exposing (HttpResponseStub)
import Elmer.Http.Stub as Stub exposing (withBody, withStatus)
import Elmer.Http.Route exposing (get, post)
import Elmer.Http.Status as Status
import Elmer.Http.Matchers exposing (hasBody)
import Elmer.Spy as Spy
import ScoreStore.HttpScoreStore as ScoreStore
import Game.Types exposing (Score)
import Http


requestScoreTests : Test
requestScoreTests =
  describe "when no score is provided"
  [ describe "when the request is successful"
    [ test "it returns the top scores in order" <|
      \() ->
        Command.given (\_ -> ScoreStore.execute "http://fake-server/scores" 5 ScoreTagger Nothing)
          |> Spy.use [ Http.serve [ scoreRequestStub [ 81, 98, 19, 27, 865, 452, 450 ] ] ]
          |> Command.expectMessages (exactly 1 <|
              Expect.equal (ScoreTagger [ 19, 27, 81, 98, 450 ])
            )
    ]
  , describe "when the request is unsuccessful"
    [ test "it returns an empty list of scores" <|
      \() ->
        Command.given (\_ -> ScoreStore.execute "http://fake-server/scores" 5 ScoreTagger Nothing)
          |> Spy.use [ Http.serve [ scoreRequestErrorStub ] ]
          |> Command.expectMessages (exactly 1 <|
              Expect.equal (ScoreTagger [])
            )
    ]
  ]


storeScoreTests : Test
storeScoreTests =
  describe "when a score is provided"
  [ describe "when the request is successful" <|
    let
      state =
        Command.given (\_ -> ScoreStore.execute "http://fake-server/scores" 5 ScoreTagger (Just 87))
          |> Spy.use [ Http.serve [ storeScoreStub 87, scoreRequestStub [ 81, 98, 19, 27, 865, 452, 450, 87 ] ] ]
    in
    [ test "it creates a score entry" <|
      \() ->
        state
          |> Http.expect (post "http://fake-server/scores") (
            exactly 1 <| hasBody "{\"score\":87}"
          )
    , test "it requests and returns the top scores in order" <|
      \() ->
        state
          |> Command.expectMessages (exactly 1 <|
              Expect.equal (ScoreTagger [ 19, 27, 81, 87, 98 ])
            )
    ]
  , describe "when the store score request fails" <|
    let
      state =
        Command.given (\_ -> ScoreStore.execute "http://fake-server/scores" 5 ScoreTagger (Just 87))
          |> Spy.use [ Http.serve [ storeScoreErrorStub, scoreRequestStub [ 81, 98, 19, 27, 865, 452, 450, 87 ] ] ]
    in
    [ test "it requests and returns the top scores in order" <|
      \() ->
        state
          |> Command.expectMessages (exactly 1 <|
              Expect.equal (ScoreTagger [ 19, 27, 81, 87, 98 ])
            )
    ]
  ]


type TestMsg
  = ScoreTagger (List Score)


storeScoreStub : Score -> HttpResponseStub
storeScoreStub score =
  Stub.for (post "http://fake-server/scores")
    |> withBody ("{\"score\":" ++ String.fromInt score ++ "}")


storeScoreErrorStub : HttpResponseStub
storeScoreErrorStub =
  Stub.for (post "http://fake-server/scores")
    |> withStatus Status.serverError


scoreRequestStub : List Score -> HttpResponseStub
scoreRequestStub scores =
  Stub.for (get "http://fake-server/scores")
    |> withBody (bodyForScores scores)


scoreRequestErrorStub : HttpResponseStub
scoreRequestErrorStub =
  Stub.for (get "http://fake-server/scores")
    |> withStatus Status.serverError


bodyForScores : List Score -> String
bodyForScores scores =
  "[" ++ String.join "," (List.map (\s -> "{\"score\":" ++ String.fromInt s ++ "}") scores) ++ "]"
