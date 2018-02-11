module UI.InputTests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Elmer exposing (TestState, Matcher, (<&&>), exactly)
import Elmer.Html as Markup exposing (HtmlElement)
import Elmer.Html.Event as Event
import Elmer.Html.Matchers exposing (element, elements, hasAttribute)
import UI
import UI.Types exposing (Model, Msg)
import Core.Types exposing (GameState(..), Color(..))
import TestHelpers exposing (..)


selectElementTests : Test
selectElementTests =
  describe "select an element of the guess"
  [ describe "when red is clicked"
    [ test "it shows that red is selected" <|
      \() ->
        selectColors [ Just "red" ]
          |> expectSelected [ "red", "empty", "empty", "empty", "empty" ]
    ]
  , describe "when orange is clicked"
    [ test "it shows that orange is selected" <|
      \() ->
        selectColors [ Just "red", Just "orange" ]
          |> expectSelected [ "red", "orange", "empty", "empty", "empty" ]
    ]
  , describe "when yellow is clicked"
    [ test "it shows that yellow is selected" <|
      \() ->
        selectColors [ Nothing, Nothing, Just "yellow" ]
          |> expectSelected [ "empty", "empty", "yellow", "empty", "empty" ]
    ]
  , describe "when green is clicked"
    [ test "it shows that green is selected" <|
      \() ->
        selectColors [ Nothing, Just "orange", Just "green" ]
          |> expectSelected [ "empty", "orange", "green", "empty", "empty" ]
    ]
  , describe "when blue is clicked"
    [ test "it shows that blue is selected" <|
      \() ->
        selectColors [ Just "red", Just "orange", Just "yellow", Just "green", Just "blue" ]
          |> expectSelected [ "red", "orange", "yellow", "green", "blue" ]
    ]
  ]


testModel : Model
testModel =
  UI.defaultModel { codeLength = 5, colors = testColors }

testColors : List Color
testColors =
  [ Red, Orange, Yellow, Blue, Green ]


testUpdate : Msg -> Model -> (Model, Cmd msg)
testUpdate =
  { guessEvaluator = \_ _ -> Cmd.none
  , restartGameCommand = Cmd.none
  }
    |> UI.update


selectColors : List (Maybe String) -> TestState Model Msg
selectColors classes =
  let
    state =
      Elmer.given testModel (UI.view <| InProgress 3) testUpdate
  in
    List.indexedMap selectColor classes
      |> foldStates state


selectColor : Int -> Maybe String -> TestState Model Msg -> TestState Model Msg
selectColor position maybeClass testState =
  case maybeClass of
    Just class ->
      testState
        |> Markup.target ("[data-guess-input='" ++ toString position ++ "'] [class='" ++ class ++ "']")
        |> Event.click
    Nothing ->
      testState


expectSelected : List String -> TestState Model Msg -> Expectation
expectSelected classes testState =
  testState
    |> Markup.target "[data-guess-input-element]"
    |> Markup.expect (elements <|
      expectElementsSelected classes
    )


expectElementsSelected : List String -> Matcher (List (HtmlElement Msg))
expectElementsSelected classes =
  List.indexedMap expectElementSelected classes
    |> expectAll


expectElementSelected : Int -> String -> Matcher (List (HtmlElement Msg))
expectElementSelected position class =
  exactly 1 (
    hasAttribute ("data-guess-input-element", toString position) <&&>
    hasAttribute ("class", class)
  )
