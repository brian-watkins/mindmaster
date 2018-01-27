module Core.PlayGuessUseCaseTests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Elmer
import Elmer.Html as Markup
import Elmer.Html.Event as Event
import Elmer.Html.Matchers exposing (element, hasText)
import Elmer.Spy as Spy exposing (Spy)
import Elmer.Spy.Matchers exposing (wasCalledWith, stringArg)
import Elmer.Platform.Command as Command
import View
import Core exposing (GuessFeedback(..), Color(..))
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events


type VMsg =
  PlayGuess

type alias VModel =
  { feedback : Maybe GuessFeedback
  }

testVModel : VModel
testVModel =
  { feedback = Nothing }

fakeViewUpdate : List Color -> (List Color -> GuessFeedback) -> VMsg -> VModel -> (VModel, Cmd VMsg)
fakeViewUpdate code playGuess msg model =
  case msg of
    PlayGuess ->
      ( { model | feedback = Just <| playGuess code }, Cmd.none )

fakeView : VModel -> Html VMsg
fakeView model =
  Html.div [ Attr.id "submit-code", Events.onClick PlayGuess ] []


fakeCodeGenerator : List Color -> Color -> List Color -> Int -> (List Color -> msg) -> Cmd msg
fakeCodeGenerator code default colors num tagger =
  Command.fake <| tagger code

yellowCode : List Color
yellowCode =
  [ Yellow, Yellow, Blue, Blue ]

orangeCode : List Color
orangeCode =
  [ Orange, Yellow, Blue, Green ]


playGuessTests : Test
playGuessTests =
  describe "when a guess is played"
  [ describe "when there is no code"
    [ test "it returns Wrong" <|
      \() ->
        Elmer.given (Core.defaultModel testVModel) (Core.view fakeView) (Core.update <| fakeViewUpdate yellowCode)
          |> Markup.target "#submit-code"
          |> Event.click
          |> Elmer.expectModel (\model ->
              Core.viewModel model
                |> .feedback
                |> Expect.equal (Just Wrong)
            )
    ]
  , describe "when there is a code"
    [ describe "when the guess is wrong"
      [ test "it returns Wrong as the feedback" <|
        \() ->
          Elmer.given (Core.defaultModel testVModel) (Core.view fakeView) (Core.update <| fakeViewUpdate yellowCode)
            |> Elmer.init (\_ -> Core.initGame (fakeCodeGenerator orangeCode) testVModel)
            |> Markup.target "#submit-code"
            |> Event.click
            |> Elmer.expectModel (\model ->
                Core.viewModel model
                  |> .feedback
                  |> Expect.equal (Just Wrong)
              )
      ]
    , describe "when the guess is correct"
      [ test "it returns Correct as the feedback" <|
        \() ->
          Elmer.given (Core.defaultModel testVModel) (Core.view fakeView) (Core.update <| fakeViewUpdate orangeCode)
            |> Elmer.init (\_ -> Core.initGame (fakeCodeGenerator orangeCode) testVModel)
            |> Markup.target "#submit-code"
            |> Event.click
            |> Elmer.expectModel (\model ->
                Core.viewModel model
                  |> .feedback
                  |> Expect.equal (Just Correct)
              )
      ]
    ]
  ]
