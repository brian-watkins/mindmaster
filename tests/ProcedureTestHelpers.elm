module ProcedureTestHelpers exposing
  ( prepare
  , send
  , run
  , spy
  , expectValue
  , expectValues
  , subscriptions
  )

import Expect
import Html exposing (Html)
import Procedure exposing (Procedure)
import Procedure.Program
import Elmer exposing (TestState)
import Elmer.Spy as Spy exposing (Spy, andCallFake)
import Elmer.Command as Command
import Task
import Process


prepare : TestState (TestModel a) (TestMsg a)
prepare =
  Elmer.given testModel testView testUpdate

spy : Spy
spy =
  processSpy

run : (() -> Procedure Never a (TestMsg a)) -> TestState (TestModel a) (TestMsg a) -> TestState (TestModel a) (TestMsg a)
run pThunk =
  Command.send (\_ ->
    pThunk ()
      |> Procedure.run ProcMessage GotMessage
  )

send : ((Procedure.Program.Msg (TestMsg a) -> TestMsg a) -> (a -> TestMsg a) -> Cmd (TestMsg a)) -> TestState (TestModel a) (TestMsg a) -> TestState (TestModel a) (TestMsg a)
send pThunk =
  Command.send (\_ ->
    pThunk ProcMessage GotMessage
  )

expectValue : a -> TestState (TestModel a) (TestMsg a) -> Expect.Expectation
expectValue expectedValue testState =
  testState
    |> Elmer.expectModel (\model ->
      case List.head model.messages of
        Just firstValue ->
          Expect.equal expectedValue firstValue
        Nothing ->
          Expect.fail "The procedure produced no value!"
    )

expectValues : List a -> TestState (TestModel a) (TestMsg a) -> Expect.Expectation
expectValues expectedValues testState =
  testState
    |> Elmer.expectModel (\model ->
      Expect.equal model.messages expectedValues
    )

type TestMsg a
  = GotMessage a
  | ProcMessage (Procedure.Program.Msg (TestMsg a))

type alias TestModel a =
  { messages : List a
  , procModel : Procedure.Program.Model (TestMsg a)
  }

testModel : TestModel a
testModel =
  { messages = []
  , procModel = Procedure.Program.init
  }

testUpdate : TestMsg a -> TestModel a -> (TestModel a, Cmd (TestMsg a))
testUpdate msg model =
  case msg of
    GotMessage data ->
      ( { model | messages = data :: model.messages }, Cmd.none )
    ProcMessage pMsg ->
      Procedure.Program.update pMsg model.procModel
        |> Tuple.mapFirst (\updated -> { model | procModel = updated })

subscriptions : TestModel a -> Sub (TestMsg a)
subscriptions model =
  Procedure.Program.subscriptions model.procModel

testView : TestModel a -> Html (TestMsg a)
testView model =
  Html.text ""

processSpy : Spy
processSpy =
  Spy.observe (\_ -> Process.sleep)
    |> andCallFake (\timeout ->
      Task.succeed ()
    )