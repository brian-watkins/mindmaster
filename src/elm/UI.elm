module UI exposing
  ( defaultModel
  , view
  , update
  )

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Core.Types exposing (GuessFeedback(..), Color(..), Code)
import UI.Types exposing (..)
import UI.Code as Code
import UI.Views.GuessHistory as GuessHistory
import UI.Views.GuessInput as GuessInput


defaultModel : Model
defaultModel =
  { guess = Nothing
  , history = []
  }


view : Model -> Html Msg
view model =
  Html.div []
  [ GuessInput.view
  , GuessHistory.view model
  ]


update : (Code -> GuessFeedback) -> Msg -> Model -> (Model, Cmd Msg)
update evaluator msg model =
  case msg of
    SubmitGuess ->
      case model.guess of
        Just guess ->
          ( evaluateGuess evaluator guess
              |> recordGuess model
          , Cmd.none
          )
        Nothing ->
          ( model, Cmd.none )
    GuessInput text ->
      ( { model | guess = Just text }
      , Cmd.none
      )


evaluateGuess : (Code -> GuessFeedback) -> String -> (String, GuessFeedback)
evaluateGuess evaluator guess =
  (guess, Code.fromString guess)
    |> Tuple.mapSecond evaluator


recordGuess : Model -> (String, GuessFeedback) -> Model
recordGuess model guessRecord =
  { model | history =
    guessRecord :: model.history
  }
