module UI.Views.GuessHistory exposing
  ( view
  )

import Core.Types exposing (GuessFeedback(..))
import UI.Types exposing (..)
import Html exposing (Html)
import Html.Attributes as Attr


view : Model -> Html Msg
view model =
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
