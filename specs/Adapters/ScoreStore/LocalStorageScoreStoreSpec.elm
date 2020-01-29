module Adapters.ScoreStore.LocalStorageScoreStoreSpec exposing (main)

import Spec exposing (..)
import Spec.Port as Port
import Spec.Claim as Claim
import Spec.Extra exposing (equals)
import Adapters.ScoreStore.Helpers as Helpers
import ScoreStore.LocalStorageScoreStore as ScoreStore
import Runner
import Json.Encode as Encode
import Json.Decode as Json


scoreStoreSpec =
  Spec.describe "Local Storage Score Store"
  [ scenario "nothing is provided to store" (
      given (
        ScoreStore.execute 5 Nothing
          |> Helpers.initWithProcedure
      )
      |> when "the scores are returned"
        [ Port.send "scores" <| Encode.list Encode.int [ 190, 124, 218, 887, 332, 97, 814 ]
        ]
      |> observeThat
        [ it "requests the scores" (
            Port.observe "requestScores" (Json.nullable Json.int)
              |> expect (Claim.isListWhere [ Claim.isNothing ])
          )
        , it "sends the top scores in order" (
            Helpers.expectValue [ 97, 124, 190, 218, 332 ]
          )
        ]
    )
  , scenario "a score is provided to store" (
      given (
        ScoreStore.execute 5 (Just 781)
          |> Helpers.initWithProcedure
      )
      |> when "the scores are returned"
        [ Port.send "scores" <| Encode.list Encode.int [ 190, 124, 218, 887, 332, 97, 814 ]
        ]
      |> observeThat
        [ it "requests the scores" (
            Port.observe "requestScores" (Json.nullable Json.int)
              |> expect (Claim.isListWhere [ equals <| Just 781 ])
          )
        , it "sends the top scores in order" (
            Helpers.expectValue [ 97, 124, 190, 218, 332 ]
          )
        ]
    )
  ]


main =
  Runner.program
    [ scoreStoreSpec
    ]