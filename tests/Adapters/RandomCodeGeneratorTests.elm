module Adapters.RandomCodeGeneratorTests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Elmer exposing (exactly)
import Elmer.Headless as Headless
import Elmer.Spy as Spy exposing (Spy, andCallFake)
import Elmer.Platform.Command as Command
import Random
import RandomCodeGenerator

type TestMsg
  = Code (List Int)


randomSpy : Spy
randomSpy =
  Spy.create "random-spy" (\_ -> Random.generate)
    |> andCallFake (\tagger generator ->
      Random.initialSeed 8745
        |> Random.step generator
        |> Tuple.first
        |> tagger
        |> Command.fake
    )


generateCodeTests : Test
generateCodeTests =
  describe "generate code"
  [ test "it generates a random code" <|
    \() ->
      Headless.givenCommand (\_ -> RandomCodeGenerator.generate 0 [ 1, 2, 3, 4 ] 5 Code)
        |> Spy.use [ randomSpy ]
        |> Headless.expectMessages (exactly 1 <|
          Expect.equal (Code [ 3, 3, 1, 2, 3 ])
        )
  ]
