module UI.Views.HighScores exposing
  ( view
  )

import Html exposing (Html)
import Html.Attributes as Attr
import UI.Types exposing (..)
import Game.Types exposing (Score)


view : Model -> Html Msg
view model =
  Html.div [ Attr.id "high-scores" ]
  [ Html.h2 [] [ Html.text "High Scores" ]
  , highScores model
  ]


highScores : Model -> Html Msg
highScores model =
  if List.isEmpty model.highScores then
    Html.p []
      [ Html.text "No scores recorded." ]
  else
    Html.ol [] <|
      List.map highScoreView model.highScores


highScoreView : Score -> Html Msg
highScoreView score =
  Html.li [ Attr.class "high-score" ]
  [ Html.text <| toString score
  ]
