module Adapters.ScoreStore.HttpScoreStoreSpec exposing (main)

import Spec exposing (..)
import Spec.Port as Port
import Spec.Claim as Claim
import Spec.Extra exposing (equals)
import Spec.Http exposing (asJson)
import Spec.Http.Stub as Stub
import Spec.Http.Route exposing (..)
import ScoreStore.HttpScoreStore as ScoreStore
import Adapters.ScoreStore.Helpers as Helpers
import Game.Types exposing (Score)
import Runner
import Json.Encode as Encode
import Json.Decode as Json


fetchFromScoreStoreSpec =
  Spec.describe "Only Fetch Scores"
  [ scenario "the request is successful" (
      given (
        ScoreStore.execute "http://fake-server/scores" 5 Nothing
          |> Helpers.initWithProcedure
          |> Stub.serve [ successfulRequestStub [ 81, 98, 19, 27, 865, 452, 450 ] ]
      )
      |> it "returns the top scores in order" (
        Helpers.expectValue [ 19, 27, 81, 98, 450 ]
      )
    )
  , scenario "the request is unsuccessful" (
      given (
        ScoreStore.execute "http://fake-server/scores" 5 Nothing
          |> Helpers.initWithProcedure
          |> Stub.serve [ failedRequestStub ]
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
          |> Stub.serve [ storeScoreStub, successfulRequestStub [ 81, 98, 19, 27, 865, 452, 450, 87 ] ]
      )
      |> observeThat
        [ it "creates a score entry" (
            Spec.Http.observeRequests (post "http://fake-server/scores")
              |> expect (Claim.isListWhere
                [ Spec.Http.body (asJson <| Json.field "score" Json.int) (equals 87)
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
          |> Stub.serve [ storeScoreErrorStub, successfulRequestStub [ 81, 98, 19, 27, 865, 452, 450, 87 ] ]
      )
      |> observeThat
        [ it "attempts to create a score entry" (
            Spec.Http.observeRequests (post "http://fake-server/scores")
              |> expect (Claim.isListWhere
                [ Spec.Http.body (asJson <| Json.field "score" Json.int) (equals 87)
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
    |> Stub.withBody (Stub.withJson <| bodyForScores scores)


failedRequestStub =
  Stub.for (get "http://fake-server/scores")
    |> Stub.withStatus 500


storeScoreStub =
  Stub.for (post "http://fake-server/scores")
    |> Stub.withBody (Stub.withText "{}")


storeScoreErrorStub =
  Stub.for (post "http://fake-server/scores")
    |> Stub.withStatus 500


bodyForScores scores =
  Encode.list (\s -> Encode.object [ ("score", Encode.int s) ]) scores


main =
  Runner.program
    [ fetchFromScoreStoreSpec
    , storeScoreSpec
    ]