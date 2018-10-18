module Game exposing
  ( Msg(..)
  , Model
  )

import Game.Types exposing (Code, GameState)
import Time exposing (Posix)


type Msg
  = Start Code
  | Judge Code
  | IncrementTimer Posix


type alias Model =
  { code : Code
  , gameState : GameState
  , maxGuesses : Int
  , guesses : Int
  , timer : Int
  }
