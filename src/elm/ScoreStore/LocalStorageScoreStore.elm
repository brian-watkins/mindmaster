port module ScoreStore.LocalStorageScoreStore exposing
  ( execute
  , subscriptions
  , requestScores
  , scores
  )

import Core.Types exposing (Score, UpdateScoreStore)


port requestScores : Maybe Score -> Cmd msg

port scores : (List Score -> msg) -> Sub msg


execute : UpdateScoreStore msg
execute maybeScore =
  requestScores maybeScore


subscriptions : (List Score -> msg) -> Sub msg
subscriptions scoreTagger =
  scores scoreTagger
