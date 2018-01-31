module UI.GameOverTests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Elmer exposing (expectNot)
import Elmer.Html as Markup
import Elmer.Html.Event as Event
import Elmer.Html.Matchers exposing (element, elementExists, hasText)
import Core.Types exposing (GameState(..), Color(..))
import UI


winTests : Test
winTests =
  describe "when the game is won" <|
  let
    state =
      Elmer.given UI.defaultModel (UI.view Won) (UI.update <| (\_ _ -> Cmd.none))
  in
  [ test "it shows the You Win message" <|
    \() ->
      state
        |> Markup.target "#game-over-message"
        |> Markup.expect (element <| hasText "You win!")
  , test "it does not show the guess input" <|
    \() ->
      state
        |> Markup.target "#guess-input"
        |> Markup.expect (expectNot <| elementExists)
  ]


lostTests : Test
lostTests =
  describe "when the game is lost" <|
  let
    state =
      Elmer.given UI.defaultModel (UI.view <| Lost [ Orange, Blue, Yellow, Red ]) (UI.update <| (\_ _ -> Cmd.none))
  in
  [ test "it says you lost and shows the code" <|
    \() ->
      state
        |> Markup.target "#game-over-message"
        |> Markup.expect (element <| hasText "You lost! The code is: obyr")
  , test "it does not show the guess input" <|
    \() ->
      state
        |> Markup.target "#guess-input"
        |> Markup.expect (expectNot <| elementExists)
  ]
