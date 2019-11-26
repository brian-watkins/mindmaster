module Adapters.ScoreStore.HttpScoreStoreSpec exposing (main)

import Spec exposing (Spec)
import Spec.Scenario exposing (..)
import Spec.Port as Port
import Spec.Claim as Claim
import Spec.Extra exposing (equals)
import Spec.Http
import Spec.Http.Stub as Stub
import Spec.Http.Route exposing (..)
import ScoreStore.HttpScoreStore as ScoreStore
import Adapters.ScoreStore.Helpers as Helpers
import Game.Types exposing (Score)
import Runner
import Json.Encode as Encode


fetchFromScoreStoreSpec =
  Spec.describe "Only Fetch Scores"
  [ scenario "the request is successful" (
      given (
        ScoreStore.execute "http://fake-server/scores" 5 Nothing
          |> Helpers.initWithProcedure
          |> Spec.Http.withStubs [ successfulRequestStub [ 81, 98, 19, 27, 865, 452, 450 ] ]
      )
      |> it "returns the top scores in order" (
        Helpers.expectValue [ 19, 27, 81, 98, 450 ]
      )
    )
  , scenario "the request is unsuccessful" (
      given (
        ScoreStore.execute "http://fake-server/scores" 5 Nothing
          |> Helpers.initWithProcedure
          |> Spec.Http.withStubs [ failedRequestStub ]
      )
      |> it "returns an empty list" (
        Helpers.expectValue []
      )
    )
  ]


storeScoreSpec =
  Spec.describe "Store Score and Fetch Scores"
  [ scenario "the store request is successful" (
      given (
        ScoreStore.execute "http://fake-server/scores" 5 (Just 87)
          |> Helpers.initWithProcedure
          |> Spec.Http.withStubs [ storeScoreStub, successfulRequestStub [ 81, 98, 19, 27, 865, 452, 450, 87 ] ]
      )
      |> observeThat
        [ it "creates a score entry" (
            Spec.Http.observeRequests (post "http://fake-server/scores")
              |> expect (Claim.isList
                [ Spec.Http.hasBody "{\"score\":87}"
                ]
              )
          )
        , it "returns the top scores in order" (
            Helpers.expectValue [ 19, 27, 81, 87, 98 ]
          )
        ]
    )
  , scenario "the store request fails" (
      given (
        ScoreStore.execute "http://fake-server/scores" 5 (Just 87)
          |> Helpers.initWithProcedure
          |> Spec.Http.withStubs [ storeScoreErrorStub, successfulRequestStub [ 81, 98, 19, 27, 865, 452, 450, 87 ] ]
      )
      |> observeThat
        [ it "attempts to create a score entry" (
            Spec.Http.observeRequests (post "http://fake-server/scores")
              |> expect (Claim.isList
                [ Spec.Http.hasBody "{\"score\":87}"
                ]
              )
          )
        , it "returns the top scores in order" (
            Helpers.expectValue [ 19, 27, 81, 87, 98 ]
          )
        ]
    )
  ]


successfulRequestStub scores =
  Stub.for (get "http://fake-server/scores")
    |> Stub.withBody (bodyForScores scores)


failedRequestStub =
  Stub.for (get "http://fake-server/scores")
    |> Stub.withStatus 500


storeScoreStub =
  Stub.for (post "http://fake-server/scores")
    |> Stub.withBody "{}"


storeScoreErrorStub =
  Stub.for (post "http://fake-server/scores")
    |> Stub.withStatus 500


bodyForScores : List Score -> String
bodyForScores scores =
  Encode.list (\s -> Encode.object [ ("score", Encode.int s) ]) scores
    |> Encode.encode 0


main =
  Runner.program
    [ fetchFromScoreStoreSpec
    , storeScoreSpec
    ]