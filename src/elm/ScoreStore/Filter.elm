module ScoreStore.Filter exposing
  ( highScores
  )

import Game.Types exposing (Score)


highScores : Int -> List Score -> List Score
highScores top scores =
  List.sort scores
    |> List.take top
