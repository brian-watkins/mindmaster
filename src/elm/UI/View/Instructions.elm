module UI.View.Instructions exposing
  ( view
  )

import UI.Types exposing (..)
import Html exposing (Html)
import Html.Attributes as Attr


view : Html Msg
view =
  Html.div [ Attr.id "instructions" ]
  [ Html.h2 [] [ Html.text "Instructions" ]
  , Html.p []
    [ Html.text instructions ]
  , Html.p []
    [ Html.text scoring ]
  ]


instructions : String
instructions =
  "Tap the colors to guess the correct code. "
    ++ "If your guess is wrong, you'll see a clue. "
    ++ "Black dots indicate the number of colors in the correct position. "
    ++ "Dark gray dots indicate the number of colors that are correct but in the wrong position."


scoring : String
scoring =
  "The score is based on time and the number of guesses. You get 1 point for every second until you guess the "
    ++ "correct code, and 50 points for each guess. The lower your score, the better! "
    ++ "Your top five scores will be saved."
