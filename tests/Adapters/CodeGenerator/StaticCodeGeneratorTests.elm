module Adapters.CodeGenerator.StaticCodeGeneratorTests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Elmer exposing (exactly)
import Elmer.Command as Command
import CodeGenerator.StaticCodeGenerator as StaticCodeGenerator


generateCodeTests : Test
generateCodeTests =
  describe "generate code"
  [ test "it returns the given code" <|
    \() ->
      Command.given (\_ -> StaticCodeGenerator.generator [ 1, 2, 3 ] CodeTagger)
        |> Command.expectMessages (
          exactly 1 <| Expect.equal (CodeTagger [ 1, 2, 3 ])
        )
  ]


type TestMsg
  = CodeTagger (List Int)
