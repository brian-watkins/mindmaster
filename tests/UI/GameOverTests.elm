module UI.GameOverTests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Elmer exposing (expectNot, atIndex, (<&&>))
import Elmer.Html as Markup
import Elmer.Html.Event as Event
import Elmer.Html.Matchers exposing (element, elements, elementExists, hasText, hasAttribute)
import Core.Types exposing (GameState(..), Color(..))
import UI
import UI.Types exposing (Msg, Model)


winTests : Test
winTests =
  describe "when the game is won" <|
  let
    state =
      Elmer.given testModel (UI.view <| Won 350) testUpdate
  in
  [ test "it shows the You Win message" <|
    \() ->
      state
        |> Markup.target "#game-over-message"
        |> Markup.expect (element <| hasText "You won!")
  , test "it shows your score" <|
    \() ->
      state
        |> Markup.target "#final-score"
        |> Markup.expect (element <| hasText "Final Score: 350")
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
      Elmer.given testModel (UI.view <| Lost [ Orange, Blue, Yellow, Red ]) testUpdate
  in
  [ test "it says you lost" <|
    \() ->
      state
        |> Markup.target "#game-over-message"
        |> Markup.expect (element <| hasText "You lost!")
  , test "it shows the actual code" <|
    \() ->
      state
        |> Markup.target "[data-code-element]"
        |> Markup.expect (elements <|
          (atIndex 0 <| hasAttribute ("class", "orange")) <&&>
          (atIndex 1 <| hasAttribute ("class", "blue")) <&&>
          (atIndex 2 <| hasAttribute ("class", "yellow")) <&&>
          (atIndex 3 <| hasAttribute ("class", "red"))
        )
  , test "it does not show the guess input" <|
    \() ->
      state
        |> Markup.target "#guess-input"
        |> Markup.expect (expectNot <| elementExists)
  ]


testUpdate : Msg -> Model -> (Model, Cmd msg)
testUpdate =
  { guessEvaluator = \_ _ -> Cmd.none
  , restartGameCommand = Cmd.none
  }
    |> UI.update

testModel : Model
testModel =
  UI.defaultModel { codeLength = 3, colors = testColors }

testColors : List Color
testColors =
  [ Red, Orange, Yellow, Blue, Green ]
