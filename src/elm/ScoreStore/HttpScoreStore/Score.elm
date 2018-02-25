module ScoreStore.HttpScoreStore.Score exposing
  ( decoder
  , encode
  )

import Json.Decode as Json exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Game.Types exposing (Score)


decoder : Decoder Score
decoder =
  Json.field "score" Json.int


encode : Score -> Value
encode score =
  Encode.object
    [ ( "score", Encode.int score )
    ]
