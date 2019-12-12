module Adapters.CodeGenerator.RandomCodeGeneratorSpec exposing (main)

import Spec exposing (..)
import Spec.Setup as Setup
import Spec.Observer as Observer
import Spec.Command as Command
import Spec.Extra exposing (equals)
import Runner
import Random
import CodeGenerator.RandomCodeGenerator as RandomCodeGenerator


generateCodeSpec : Spec Model Msg
generateCodeSpec =
  Spec.describe "random code generator"
  [ scenario "a code is generated" (
      given (
        Setup.init ( testModel, RandomCodeGenerator.generator testGenerator 5 0 [ 1, 2, 3, 4 ] CodeTagger )
          |> Setup.withUpdate testUpdate
      )
      |> it "returns a random code" (
        Observer.observeModel .generatedCode
          |> expect (equals [ 4, 4, 3, 2, 1 ])
      )
    )
  ]


testGenerator tagger generator =
  Random.initialSeed 9126
    |> Random.step generator
    |> Tuple.first
    |> tagger
    |> Command.fake


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