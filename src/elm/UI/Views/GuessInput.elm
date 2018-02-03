module UI.Views.GuessInput exposing
  ( view
  )

import UI.Types exposing (..)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events


view : Model -> Html Msg
view model =
  Html.div []
  [ Html.text "Enter a guess (r, o, y, g, b)"
  , Html.input
    [ Attr.id "guess-input"
    , Events.onInput GuessInput
    , Attr.value <| Maybe.withDefault "" model.guess
    ] []
  , Html.button [ Attr.id "guess-submit", Events.onClick SubmitGuess ]
    [ Html.text "Submit guess" ]
  ]
