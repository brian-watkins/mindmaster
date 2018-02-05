module UI.Views.SubmitGuess exposing
  ( view
  )

import UI.Types exposing (..)
import Html exposing (Html)
import Html.Events as Events
import Html.Attributes as Attr


view : Model -> Html Msg
view model =
  Html.div [ Attr.class "row" ]
  [ Html.div [ Attr.id "submit-guess", Events.onClick SubmitGuess ]
    [ Html.text "Submit Guess" ]
  ]
