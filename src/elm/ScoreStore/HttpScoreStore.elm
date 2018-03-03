module ScoreStore.HttpScoreStore exposing
  ( execute
  )

import Game.Types exposing (Score, UpdateScoreStore)
import ScoreStore.HttpScoreStore.Score as HttpScore
import ScoreStore.Filter as Filter
import Http
import Task exposing (Task)
import Json.Decode as Json


execute : String -> Int -> (List Score -> msg) -> UpdateScoreStore msg
execute uri top tagger maybeScore =
  let
    tagHighScores = highScoreTagger top tagger
    storeScore = storeScoreTask uri
    getScores = getScoresTask uri
  in
    case maybeScore of
      Just score ->
        storeScore score
          |> Task.andThen (\_ -> getScores)
          |> Task.attempt tagHighScores
      Nothing ->
        getScores
          |> Task.attempt tagHighScores


storeScoreTask : String -> Score -> Task Http.Error ()
storeScoreTask uri score =
  Http.post uri (Http.jsonBody <| HttpScore.encode score) (Json.succeed ())
    |> Http.toTask
    |> Task.onError (\_ -> Task.succeed ())


getScoresTask : String -> Task Http.Error (List Score)
getScoresTask uri =
  Http.get uri (Json.list HttpScore.decoder)
    |> Http.toTask


highScoreTagger : Int -> (List Score -> msg) -> Result Http.Error (List Score) -> msg
highScoreTagger top tagger result =
  case result of
    Ok scores ->
      Filter.highScores top scores
        |> tagger
    Err _ ->
      tagger []
