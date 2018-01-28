module UI.Views.GuessHistory exposing
  ( view
  )

import Core.Types exposing (GuessFeedback(..))
import UI.Types exposing (..)
import UI.Views.Feedback as Feedback
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
  , Feedback.view feedback
  ]
