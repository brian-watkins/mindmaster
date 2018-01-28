module Core exposing
  ( Model
  , Msg
  , defaultModel
  , initGame
  , update
  , view
  , viewModel
  )

import Html exposing (Html)
import Core.Code as Code
import Core.Clue as Clue
import Core.Types exposing (GuessFeedback(..), Color(..))
import Core.Command.EvaluateGuess as EvaluateGuess



type Msg viewMsg
  = SetCode (List Color)
  | ViewMsg viewMsg

type alias Model vModel =
  { code : Maybe (List Color)
  , viewModel : vModel
  }


defaultModel : viewModel -> Model viewModel
defaultModel vModel =
  { code = Nothing
  , viewModel = vModel
  }


viewModel : Model viewModel -> viewModel
viewModel model =
  model.viewModel

type alias CodeGenerator viewMsg =
  Color -> List Color -> Int -> (List Color -> Msg viewMsg) -> Cmd (Msg viewMsg)

initGame : CodeGenerator viewMsg -> viewModel -> (Model viewModel, Cmd (Msg viewMsg))
initGame codeGenerator viewModel =
  (defaultModel viewModel, Code.generate SetCode codeGenerator)


type alias ViewUpdate msg model =
  (List Color -> GuessFeedback) -> msg -> model -> (model, Cmd msg)


update : ViewUpdate viewMsg viewModel -> Msg viewMsg -> Model viewModel -> (Model viewModel, Cmd (Msg viewMsg))
update viewUpdate msg model =
  case msg of
    SetCode code ->
      let
        d = Debug.log "The secret code is" code
      in
        ( { model | code = Just code }, Cmd.none )
    ViewMsg viewMsg ->
      let
        (vmodel, vmsg) =
          viewUpdate (evaluateGuess model) viewMsg model.viewModel
      in
        ( { model | viewModel = vmodel }, Cmd.none )


evaluateGuess : Model viewModel -> List Color -> GuessFeedback
evaluateGuess model guess =
  case model.code of
    Just code ->
      EvaluateGuess.execute code guess
    Nothing ->
      Clue.with 0 0
        |> Wrong


type alias ViewView viewModel viewMsg =
  viewModel -> Html viewMsg

view : ViewView viewModel viewMsg -> Model viewModel -> Html (Msg viewMsg)
view viewView model =
  viewView model.viewModel
    |> Html.map ViewMsg
