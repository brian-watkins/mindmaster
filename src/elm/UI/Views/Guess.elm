module UI.Views.Guess exposing
  ( view
  )

import UI.Types exposing (..)
import Html exposing (Html)


view : String -> Html Msg
view guess =
  Html.text guess
