module Configuration exposing
  ( program
  , coreAdapters
  )

import Html exposing (Html)
import Bus
import Game.Types exposing (defaultColor, Color(..))
import UI
import UI.Types as UI
import UI.Action
import UI.View
import CodeGenerator.RandomCodeGenerator as RandomCodeGenerator
import ScoreStore.LocalStorageScoreStore as LocalStorageScoreStore


colors =
  [ Red
  , Orange
  , Yellow
  , Green
  , Blue
  ]


type alias Model =
  { bus : Bus.Model UI.Model
  , config : Config
  }


type alias Config =
  { maxGuesses : Int
  , topScores : Int
  , codeLength : Int
  }


viewConfig config =
  { codeLength = config.codeLength
  , colors = colors
  }


defaultViewModel config =
  viewConfig config
    |> UI.defaultModel


coreAdapters config =
  { codeGenerator = RandomCodeGenerator.generator config.codeLength defaultColor colors
  , updateUI = UI.Action.update
  , guessResultTagger = UI.guessResultTagger
  , updateScoreStore = LocalStorageScoreStore.execute
  }


init adapters config =
  Bus.init { maxGuesses = config.maxGuesses } (adapters config) (defaultViewModel config)
    |> Tuple.mapFirst (\m -> { bus = m, config = config })


view : Model -> Html (Bus.Msg UI.Msg)
view model =
  Bus.view UI.View.for model.bus


update adapters msg model =
  Bus.update (adapters model.config) msg model.bus
    |> Tuple.mapFirst (\m -> { model | bus = m })


subscriptions : Model -> Sub (Bus.Msg UI.Msg)
subscriptions model =
  Sub.batch
  [ Bus.subscriptions model.bus
  , LocalStorageScoreStore.subscriptions model.config.topScores (Bus.uiTagger << UI.highScoresTagger)
  ]


program adapters =
  Html.programWithFlags
    { init = init adapters
    , view = view
    , update = update adapters
    , subscriptions = subscriptions
    }
