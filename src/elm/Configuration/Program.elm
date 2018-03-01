module Configuration.Program exposing
  ( with
  )

import Html exposing (Html)


type alias ProgramDefinition config model msg =
  { init : config -> (model, Cmd msg)
  , view : config -> model -> Html msg
  , update : config -> msg -> model -> (model, Cmd msg)
  , subscriptions : config -> model -> Sub msg
  }


type alias Model config model =
  { program : model
  , config : config
  }


with program =
  Html.programWithFlags
    { init = storeInitialModels program.init
    , view = configurableView program.view
    , update = configurableUpdate program.update
    , subscriptions = configurableSubscriptions program.subscriptions
    }


storeInitialModels programInit config =
  programInit config
    |> Tuple.mapFirst (\m -> { program = m, config = config })


configurableView programView model =
  programView model.config model.program


configurableUpdate programUpdate msg model =
  programUpdate model.config msg model.program
    |> Tuple.mapFirst (\m -> { model | program = m })


configurableSubscriptions programSubscriptions model =
  programSubscriptions model.config model.program
