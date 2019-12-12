module Adapters.CodeGenerator.StaticCodeGeneratorSpec exposing (main)

import Spec exposing (..)
import Spec.Setup as Setup
import Spec.Observer as Observer
import Spec.Extra exposing (equals)
import Runner
import CodeGenerator.StaticCodeGenerator as StaticCodeGenerator


generateCodeSpec : Spec Model Msg
generateCodeSpec =
  Spec.describe "static code generator"
  [ scenario "a code is provided" (
      given (
        Setup.init ( testModel, StaticCodeGenerator.generator [ 1, 2, 3 ] CodeTagger )
          |> Setup.withUpdate testUpdate
      )
      |> it "returns the provided code" (
        Observer.observeModel .generatedCode
          |> expect (equals [ 1, 2, 3])
      )
    )
  ]


type Msg
  = CodeTagger (List Int)


type alias Model =
  { generatedCode: List Int
  }


testModel : Model
testModel =
  { generatedCode = []
  }


testUpdate : Msg -> Model -> (Model, Cmd Msg)
testUpdate msg model =
  case msg of
    CodeTagger code ->
      ( { model | generatedCode = code }, Cmd.none )


main =
  Runner.program
    [ generateCodeSpec
    ]