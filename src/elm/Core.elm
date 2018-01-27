module Core exposing
  ( GuessFeedback(..)
  , Color(..)
  , Model
  , Msg
  , defaultModel
  , initGame
  , update
  , view
  , viewModel
  , playGuess
  )

import Html exposing (Html)


type GuessFeedback
  = Wrong
  | Correct

type Color
  = Red
  | Orange
  | Yellow
  | Green
  | Blue

colors : List Color
colors =
  [ Red
  , Orange
  , Yellow
  , Green
  , Blue
  ]


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
  (defaultModel viewModel, codeGenerator Blue colors 5 SetCode)


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
          viewUpdate (playGuess model) viewMsg model.viewModel
      in
        ( { model | viewModel = vmodel }, Cmd.none )


playGuess : Model viewModel -> List Color -> GuessFeedback
playGuess model guess =
  case model.code of
    Just code ->
      if equalsCode code guess then
        Correct
      else
        Wrong
    Nothing ->
      Wrong

equalsCode : List Color -> List Color -> Bool
equalsCode expected actual =
  case expected of
    [] ->
      List.isEmpty actual
    x :: xl ->
      case List.head actual of
        Just h ->
          if x == h then
            equalsCode xl (List.drop 1 actual)
          else
            False
        Nothing ->
          False

type alias ViewView viewModel viewMsg =
  viewModel -> Html viewMsg

view : ViewView viewModel viewMsg -> Model viewModel -> Html (Msg viewMsg)
view viewView model =
  viewView model.viewModel
    |> Html.map ViewMsg
