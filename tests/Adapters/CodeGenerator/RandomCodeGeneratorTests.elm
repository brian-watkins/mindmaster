module Adapters.CodeGenerator.RandomCodeGeneratorTests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Elmer exposing (exactly)
import Elmer.Spy as Spy exposing (Spy, andCallFake)
import Elmer.Command as Command
import Random
import CodeGenerator.RandomCodeGenerator as RandomCodeGenerator


generateCodeTests : Test
generateCodeTests =
  describe "generate code"
  [ test "it generates a random code" <|
    \() ->
      Command.given (\_ -> RandomCodeGenerator.generator 5 0 [ 1, 2, 3, 4 ] Code)
        |> Spy.use [ randomSpy ]
        |> Command.expectMessages (exactly 1 <|
          Expect.equal (Code [ 4, 4, 3, 2, 1 ])
        )
  ]


type TestMsg
  = Code (List Int)


randomSpy : Spy
randomSpy =
  Spy.observe (\_ -> Random.generate)
    |> andCallFake (\tagger generator ->
      Random.initialSeed 9126
        |> Random.step generator
        |> Tuple.first
        |> tagger
        |> Command.fake
    )
