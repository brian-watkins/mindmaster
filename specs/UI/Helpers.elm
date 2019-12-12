module UI.Helpers exposing
  ( testSubject
  , testModel
  , testView
  , testUpdate
  , itEvaluatesTheGuess
  , itRestartsTheGame
  )

import Spec.Witness as Witness exposing (Witness)
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
    |> Witness.forUpdate (testUpdate (\_ -> Wrong { colors = 0, positions = 0 }))
    |> Setup.withView (testView status)


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
  UI.Action.update <|
    { guessEvaluator = fakeEvaluator witness guessResultGenerator
    , restartGame = Witness.log "restart-game" (Encode.null) witness
    }


fakeEvaluator witness feedbackGenerator code =
  Cmd.batch
  [ UI.guessResultTagger code (feedbackGenerator code)
      |> Command.fake
  , Witness.log "guess-to-evaluate" (Encode.list (\color -> Color.toClass color |> Encode.string) code) witness
  ]


itEvaluatesTheGuess expectedGuess =
  it "sends the guess to the evaluator" (
    Witness.observe "guess-to-evaluate" (Json.list Json.string)
      |> expect (isListWhere
        [ equals expectedGuess
        ]
      )
  )


itRestartsTheGame =
  it "sends the command to restart the game" (
    Witness.observe "restart-game" (Json.value)
      |> expect (isListWithLength 1)
  )