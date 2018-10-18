module UI.View.GuessHistory exposing
  ( view
  )

import Game.Types exposing (Code, GuessResult(..))
import UI.Types exposing (..)
import UI.View.GuessResult as GuessResult
import UI.View.Code as Code
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


printHistoryItem : Int -> Int -> (Code, GuessResult) -> Html Msg
printHistoryItem codeLength index (guess, guessResult) =
  Html.li
    [ Attr.class "guess-history-item"
    , Attr.attribute "data-guess-feedback" <| String.fromInt index
    ]
    [ Code.view "guess" guess
    , GuessResult.view codeLength guessResult
    ]
