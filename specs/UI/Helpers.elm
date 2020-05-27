module UI.Helpers exposing
  ( testSubject
  , testModel
  , testView
  , testUpdate
  , itEvaluatesTheGuess
  , itRestartsTheGame
  )

import Spec.Witness.Extra as Witness
import Spec.Witness
import Spec.Command as Command
import Spec.Setup as Setup
import Spec.Extra exposing (equals)
import Spec.Claim exposing (isListWhere, isListWithLength)
import Spec exposing (it, expect)
import UI
import UI.Action
import UI.View
import UI.Types exposing (..)
import Game.Types exposing (..)
import UI.Entity.Color as Color
import Json.Encode as Encode
import Json.Decode as Json


testSubject status =
  Setup.initWithModel (testModel 3)
    |> Setup.withUpdate (testUpdate (\_ -> Wrong { colors = 0, positions = 0 }))
    |> Setup.withView (testView status)


testModel : Int -> Model
testModel codeLength =
  UI.defaultModel { codeLength = codeLength, colors = testColors }


testColors : List Color
testColors =
  [ Red, Orange, Yellow, Blue, Green ]


testView status =
  UI.View.with status


testUpdate : (Code -> GuessResult) -> Msg -> Model -> (Model, Cmd Msg)
testUpdate guessResultGenerator =
  UI.Action.update <|
    { guessEvaluator = fakeEvaluator guessResultGenerator
    , restartGame = Witness.record "restart-game" (Encode.null)
    }


fakeEvaluator feedbackGenerator code =
  Cmd.batch
  [ UI.guessResultTagger code (feedbackGenerator code)
      |> Command.fake
  , Witness.record "guess-to-evaluate" (Encode.list (\color -> Color.toClass color |> Encode.string) code)
  ]


itEvaluatesTheGuess expectedGuess =
  it "sends the guess to the evaluator" (
    Spec.Witness.observe "guess-to-evaluate" (Json.list Json.string)
      |> expect (isListWhere
        [ equals expectedGuess
        ]
      )
  )


itRestartsTheGame =
  it "sends the command to restart the game" (
    Spec.Witness.observe "restart-game" (Json.value)
      |> expect (isListWithLength 1)
  )