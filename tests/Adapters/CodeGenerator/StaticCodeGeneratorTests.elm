module Adapters.CodeGenerator.StaticCodeGeneratorTests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Elmer exposing (exactly)
import Elmer.Headless as Headless
import CodeGenerator.StaticCodeGenerator as StaticCodeGenerator


generateCodeTests : Test
generateCodeTests =
  describe "generate code"
  [ test "it returns the given code" <|
    \() ->
      Headless.givenCommand (\_ -> StaticCodeGenerator.generator [ 1, 2, 3 ] CodeTagger)
        |> Headless.expectMessages (
          exactly 1 <| Expect.equal (CodeTagger [ 1, 2, 3 ])
        )
  ]


type TestMsg
  = CodeTagger (List Int)
