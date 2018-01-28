module UI.Views.Feedback exposing
  ( view
  )

import Core.Types exposing (GuessFeedback(..))
import UI.Types exposing (..)
import Html exposing (Html)


view : GuessFeedback -> Html Msg
view feedback =
  case feedback of
    Wrong clue ->
      let
        clueText =
          "Wrong. "
            ++ colorString clue.colors
            ++ " correct."
      in
        if clue.positions > 0 then
          clueText
            ++ " "
            ++ positionString clue.positions
            ++ " in the right position."
          |> Html.text
        else
          Html.text clueText
    Correct ->
      Html.text "Correct!"


colorString : Int -> String
colorString num =
  if num == 1 then
    "1 color"
  else
    toString num
      ++ " colors"


positionString : Int -> String
positionString num =
  if num == 1 then
    "1 is"
  else
    toString num
      ++ " are"
