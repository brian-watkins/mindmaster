port module ScoreStore.LocalStorageScoreStore exposing
  ( execute
  , subscriptions
  , requestScores
  , scores
  )

import Game.Types exposing (Score, UpdateScoreStore)
import ScoreStore.Filter as Filter


port requestScores : Maybe Score -> Cmd msg


port scores : (List Score -> msg) -> Sub msg


execute : UpdateScoreStore msg
execute maybeScore =
  requestScores maybeScore


subscriptions : Int -> (List Score -> msg) -> Sub msg
subscriptions top tagger =
  highScores top tagger
    |> scores


highScores : Int -> (List Score -> msg) -> List Score -> msg
highScores top tagger scoreList =
  Filter.highScores top scoreList
    |> tagger
