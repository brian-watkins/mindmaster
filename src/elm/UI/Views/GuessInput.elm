module UI.Views.GuessInput exposing
  ( view
  )

import UI.Types exposing (..)
import UI.Code as Code
import UI.Views.SubmitGuess as SubmitGuess
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Svg exposing (Svg, Attribute)
import Svg.Attributes as Sattr
import Core.Types exposing (Color(..))


view : Model -> Html Msg
view model =
  Html.div []
  [ Html.div [ Attr.class "row" ] <| guessInputs model
  , SubmitGuess.view model
  ]


guessInputs : Model -> List (Html Msg)
guessInputs model =
  List.range 0 4
    |> List.map (\index -> guessInput model index)


guessInput : Model -> Int -> Html Msg
guessInput model index =
  Html.div
  [ Attr.class "guess-input-element"
  , Attr.attribute "data-guess-input" <| toString index
  ]
  [ Svg.svg [ Sattr.viewBox "0 0 30 30" ]
    [ centeredCircle 15
      [ Sattr.class "red"
      , Events.onClick <| GuessInput index Red
      ]
    , arcPath index 0.8 Yellow
    , arcPath index 0.6 Orange
    , arcPath index 0.4 Blue
    , arcPath index 0.2 Green
    , centeredCircle 10
      [ Sattr.fill "white"
      ]
    , centeredCircle 8.5
      [ Attr.attribute "data-guess-input-element" <| toString index
      , Sattr.class <| colorToClass (colorAt index model.guess)
      ]
    ]
  ]


colorAt : Int -> Guess -> Maybe Color
colorAt position guess =
  List.drop position guess
    |> List.head
    |> Maybe.withDefault Nothing


colorToClass : Maybe Color -> String
colorToClass maybeColor =
  case maybeColor of
    Just c ->
      Code.colorToClass c
    Nothing ->
      "empty"


centeredCircle : Float -> List (Attribute Msg) -> Svg Msg
centeredCircle radius attrs =
  Svg.circle (
    List.append attrs
      [ Sattr.cx "15"
      , Sattr.cy "15"
      , Sattr.r <| toString radius
      ]
  ) []


type alias ArcSegment =
  { x : String
  , y : String
  }


arcPath : Int -> Float -> Color -> Svg Msg
arcPath index extent color =
  let
    segment = arcSegment extent
    switch =
      if extent > 0.5 then "1" else "0"
  in
    Svg.path
      [ Sattr.d <| "M 15 15 l 0 -15 a 15 15 0 " ++ switch ++ " 1 " ++ segment.x ++ " " ++ segment.y ++ " Z"
      , Sattr.class <| Code.colorToClass color
      , Events.onClick <| GuessInput index color
      ] []


radians : Float -> Float
radians extent =
  (pi * 2) * extent


arcSegment : Float -> ArcSegment
arcSegment extent =
  { x = toString <| sin (radians extent) * 15
  , y = toString <| 15 - (cos (radians extent) * 15)
  }
