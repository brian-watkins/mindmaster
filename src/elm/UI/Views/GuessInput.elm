module UI.Views.GuessInput exposing
  ( view
  )

import UI.Types exposing (..)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events


view : Html Msg
view =
  Html.div []
  [ Html.text "Enter a guess (r, g, b, y, p, o)"
  , Html.input [ Attr.id "guess-input", Events.onInput GuessInput ] []
  , Html.button [ Attr.id "guess-submit", Events.onClick SubmitGuess ]
    [ Html.text "Submit guess" ]
  ]
