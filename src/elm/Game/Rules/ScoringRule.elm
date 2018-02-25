module Game.Rules.ScoringRule exposing
  ( apply
  )

import Game.Types exposing (Score)


type alias Model a =
  { a
  | guesses : Int
  , timer : Int
  }


apply : Model a -> Score
apply model =
  model.timer + (model.guesses * 50)
