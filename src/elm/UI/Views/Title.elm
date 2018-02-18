module UI.Views.Title exposing
  ( view
  )

import Html exposing (Html)
import Html.Attributes as Attr
import UI.Types exposing (..)


view : Html Msg
view =
  Html.div [ Attr.id "title", Attr.class "row" ]
  [ Html.text "MindMaster"
  ]
