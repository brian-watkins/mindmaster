module UI.Views.GuessHistory exposing
  ( view
  )

import Core.Types exposing (Code, GuessFeedback(..))
import UI.Types exposing (..)
import UI.Views.Feedback as Feedback
import UI.Views.Guessed as Guessed
import Html exposing (Html)
import Html.Attributes as Attr


view : Model -> Html Msg
view model =
  Html.div [ Attr.id "feedback", Attr.class "row" ]
  [ feedbackHistory model ]


feedbackHistory : Model -> Html Msg
feedbackHistory model =
  model.history
    |> List.indexedMap (printHistoryItem model.codeLength)
    |> Html.ul []


printHistoryItem : Int -> Int -> (Code, GuessFeedback) -> Html Msg
printHistoryItem codeLength index (guess, feedback) =
  Html.li
    [ Attr.class "guess-history-item"
    , Attr.attribute "data-guess-feedback" <| toString index
    ]
    [ Guessed.view guess
    , Feedback.view codeLength feedback
    ]
