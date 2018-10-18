module UI.View.Progress exposing
  ( view
  )

import Html exposing (Html)
import Html.Attributes as Attr


view : Int -> Html msg
view remainingGuesses =
  Html.div [ Attr.id "game-progress", Attr.class "row" ]
    [ Html.text <| remainingGuessText remainingGuesses
    ]


remainingGuessText : Int -> String
remainingGuessText remainingGuesses =
  if remainingGuesses == 1 then
    "Last guess!"
  else
    String.fromInt remainingGuesses ++ " guesses remain!"
