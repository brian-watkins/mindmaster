module UI exposing
  ( Model
  , Msg
  , defaultModel
  , view
  , update
  )

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Core.Types exposing (GuessFeedback(..), Color(..))
import UI.Code as Code


type Msg
  = GuessInput String
  | SubmitGuess


type alias Model =
  { guess : Maybe String
  , history : List (String, GuessFeedback)
  }


defaultModel : Model
defaultModel =
  { guess = Nothing
  , history = []
  }


view : Model -> Html Msg
view model =
  Html.div []
  [ guessInput
  , feedbackDisplay model
  ]


feedbackDisplay : Model -> Html Msg
feedbackDisplay model =
  Html.div [ Attr.id "feedback" ]
  [ feedbackHistory model ]


feedbackHistory : Model -> Html Msg
feedbackHistory model =
  model.history
    |> List.indexedMap printHistoryItem
    |> Html.ol [ Attr.reversed True ]


printHistoryItem : Int -> (String, GuessFeedback) -> Html Msg
printHistoryItem index (guess, feedback) =
  Html.li [ Attr.attribute "data-guess-feedback" <| toString index ]
  [ Html.text guess
  , Html.text " => "
  , Html.text <| printFeedback feedback
  ]


printFeedback : GuessFeedback -> String
printFeedback feedback =
  case feedback of
    Wrong ->
      "Wrong."
    Correct ->
      "Correct!"


guessInput : Html Msg
guessInput =
  Html.div []
  [ Html.text "Enter a guess (r, g, b, y, p, o)"
  , Html.input [ Attr.id "guess-input", Events.onInput GuessInput ] []
  , Html.button [ Attr.id "guess-submit", Events.onClick SubmitGuess ]
    [ Html.text "Submit guess" ]
  ]


update : (List Color -> GuessFeedback) -> Msg -> Model -> (Model, Cmd Msg)
update playGuess msg model =
  case msg of
    SubmitGuess ->
      case model.guess of
        Just guess ->
          ( { model | history =
              (guess, Code.fromString guess)
                |> Tuple.mapSecond playGuess
                |> flip (::) model.history
            }
          , Cmd.none
          )
        Nothing ->
          ( model, Cmd.none )
    GuessInput text ->
      ( { model | guess = Just text }
      , Cmd.none
      )
