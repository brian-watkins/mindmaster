module ScoreStore.HttpScoreStore exposing
  ( execute
  )

import Game.Types exposing (Score)
import ScoreStore.HttpScoreStore.Score as HttpScore
import ScoreStore.Filter as Filter
import Http
import Procedure exposing (Procedure)
import Json.Decode as Json


execute : String -> Int -> Maybe Score -> Procedure Never (List Score) msg
execute uri top maybeScore =
  case maybeScore of
    Just score ->
      Procedure.fetch (storeScore uri score)
        |> Procedure.andThen (\_ -> fetchHighScores uri top)
    Nothing ->
      fetchHighScores uri top


fetchHighScores uri top =
  Procedure.fetchResult (getScores uri)
    |> Procedure.map (Filter.highScores top)
    |> Procedure.catch (\_ -> Procedure.provide [])


storeScore : String -> Score -> (Result Http.Error () -> msg) -> Cmd msg
storeScore uri score tagger =
  Http.post
    { url = uri
    , body = Http.jsonBody <| HttpScore.encode score
    , expect = Http.expectJson tagger (Json.succeed ())
    }


getScores : String -> (Result Http.Error (List Score) -> msg) -> Cmd msg
getScores uri tagger =
  Http.get
    { url = uri
    , expect = Http.expectJson tagger (Json.list HttpScore.decoder)
    }
