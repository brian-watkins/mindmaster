port module ScoreStore.LocalStorageScoreStore exposing
  ( execute
  , requestScores
  , scores
  )

import Game.Types exposing (Score)
import ScoreStore.Filter as Filter
import Procedure exposing (Procedure)
import Procedure.Channel as Channel


port requestScores : Maybe Score -> Cmd msg


port scores : (List Score -> msg) -> Sub msg


execute : Int -> Maybe Score -> Procedure Never (List Score) msg
execute length maybeScore =
  Channel.open (\_ -> requestScores maybeScore)
    |> Channel.connect scores
    |> Channel.acceptOne
    |> Procedure.map (Filter.highScores length)
