module Adapters.ScoreStore.Helpers exposing
  ( initWithProcedure
  , expectValue
  , expectValues
  )

import Spec
import Spec.Setup as Setup exposing (Setup)
import Spec.Step as Step
import Spec.Claim as Claim
import Spec.Extra exposing (equals)
import Spec.Observer as Observer exposing (Expectation)
import Spec.Report as Report
import Spec.Command as Command
import Procedure exposing (Procedure)
import Procedure.Program


initWithProcedure : Procedure Never a (TestMsg a) -> Setup (TestModel a) (TestMsg a)
initWithProcedure procedure =
  Setup.init
      ( testModel
      , Procedure.run ProcedureMsg GotMessage procedure
      )
    |> Setup.withUpdate testUpdate
    |> Setup.withSubscriptions testSubscriptions


expectValue : a -> Expectation (TestModel a)
expectValue expected =
  Observer.observeModel .messages
    |> Spec.expect (\messages ->
      List.head messages
        |> Maybe.map (equals expected)
        |> Maybe.withDefault (Claim.Reject <| Report.note "No messages received from procedure!")
    )


expectValues : List a -> Expectation (TestModel a)
expectValues expected =
  Observer.observeModel .messages
    |> Spec.expect (equals expected)


type TestMsg a
  = GotMessage a
  | ProcedureMsg (Procedure.Program.Msg (TestMsg a))

type alias TestModel a =
  { messages : List a
  , procedureModel : Procedure.Program.Model (TestMsg a)
  }

testModel : TestModel a
testModel =
  { messages = []
  , procedureModel = Procedure.Program.init
  }

testUpdate : TestMsg a -> TestModel a -> (TestModel a, Cmd (TestMsg a))
testUpdate msg model =
  case msg of
    GotMessage data ->
      ( { model | messages = data :: model.messages }, Cmd.none )
    ProcedureMsg pMsg ->
      Procedure.Program.update pMsg model.procedureModel
        |> Tuple.mapFirst (\updated -> { model | procedureModel = updated })

testSubscriptions : TestModel a -> Sub (TestMsg a)
testSubscriptions model =
  Procedure.Program.subscriptions model.procedureModel