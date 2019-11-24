module UI.Helpers exposing
  ( testSubject
  , testModel
  , testView
  , testUpdate
  , itEvaluatesTheGuess
  )

import Spec.Witness as Witness exposing (Witness)
import Spec.Command as Command
import Spec.Subject as Subject
import Spec.Extra exposing (equals)
import Spec.Claim exposing (isList)
import Spec.Scenario exposing (it, expect)
import UI
import UI.Action
import UI.View
import UI.Types exposing (..)
import Game.Types exposing (..)
import UI.Entity.Color as Color
import Json.Encode as Encode
import Json.Decode as Json


viewDependencies =
  { guessEvaluator = \_ -> Cmd.none
  , restartGame = Cmd.none
  }


testSubject status =
  Subject.initWithModel (testModel 3)
    |> Witness.forUpdate (testUpdate (\_ -> Wrong { colors = 0, positions = 0 }))
    |> Subject.withView (testView status)


testModel : Int -> Model
testModel codeLength =
  UI.defaultModel { codeLength = codeLength, colors = testColors }


testColors : List Color
testColors =
  [ Red, Orange, Yellow, Blue, Green ]


testView status =
  UI.View.with status


testUpdate : (Code -> GuessResult) -> Witness Msg -> Msg -> Model -> (Model, Cmd Msg)
testUpdate guessResultGenerator witness =
  let
    dependencies = viewDependencies
  in
    UI.Action.update <|
      { dependencies | guessEvaluator = fakeEvaluator witness guessResultGenerator }


fakeEvaluator witness feedbackGenerator code =
  Cmd.batch
  [ UI.guessResultTagger code (feedbackGenerator code)
      |> Command.fake
  , Witness.log "guess-to-evaluate" (Encode.list (\color -> Color.toClass color |> Encode.string) code) witness
  ]


itEvaluatesTheGuess expectedGuess =
  it "sends the guess to the evaluator" (
    Witness.observe "guess-to-evaluate" (Json.list Json.string)
      |> expect (isList
        [ equals expectedGuess
        ]
      )
  )
