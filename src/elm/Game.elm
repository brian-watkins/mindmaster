module Game exposing
  ( Msg(..)
  , Model
  )

import Game.Types exposing (Code, GameState)
import Time exposing (Time)


type Msg
  = Start Code
  | Judge Code
  | IncrementTimer Time


type alias Model =
  { code : Code
  , gameState : GameState
  , maxGuesses : Int
  , guesses : Int
  , timer : Int
  }
