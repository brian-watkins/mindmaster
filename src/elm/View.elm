module View exposing
  ( Model
  , Msg
  , defaultModel
  , view
  , update
  )

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Core exposing (GuessFeedback(..), Color(..))


type Msg
  = GuessInput String
  | SubmitGuess


type alias Model =
  { guess : Maybe String
  , feedback : Maybe GuessFeedback
  }


defaultModel : Model
defaultModel =
  { guess = Nothing
  , feedback = Nothing
  }


view : Model -> Html Msg
view model =
  Html.div []
  [ guessInput
  , feedbackDisplay model
  ]


feedbackDisplay : Model -> Html Msg
feedbackDisplay model =
  case model.feedback of
    Just feedback ->
      Html.div [ Attr.id "feedback" ]
      [ Html.div [ Attr.attribute "data-guess-feedback" "" ]
        [ Html.text <| printFeedback feedback ]
      ]
    Nothing ->
      Html.div [] []


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
          ( { model | feedback = Just <| playGuess <| toCode guess [] }
          , Cmd.none
          )
        Nothing ->
          ( model, Cmd.none )
    GuessInput text ->
      ( { model | guess = Just text }
      , Cmd.none
      )


toCode : String -> List Color -> List Color
toCode guess code =
  case String.uncons guess of
    Just (c, str) ->
      [ toColor c ]
        |> List.append code
        |> toCode str
    Nothing ->
      code

toColor : Char -> Color
toColor c =
  case c of
    'r' -> Red
    'o' -> Orange
    'y' -> Yellow
    'g' -> Green
    _ -> Blue
