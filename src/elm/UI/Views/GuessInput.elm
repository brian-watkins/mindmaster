module UI.Views.GuessInput exposing
  ( view
  )

import UI.Types exposing (..)
import UI.Code as Code
import UI.Guess as Guess
import UI.Views.SubmitGuess as SubmitGuess
import UI.Vectors.Circle as Circle
import UI.Vectors.Wedge as Wedge
import UI.Vectors.Attribute as Vector
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
    [ selectableColors index colors
    , boundary
    , selectedColor index model
    ]
  ]


selectedColor : Int -> Model -> Svg Msg
selectedColor index model =
  let
    guessColor =
      Guess.colorAt index model.guess
  in
    Circle.unit 8.5
      [ Attr.attribute "data-guess-input-element" <| toString index
      , Vector.classList
        [ ( colorToClass guessColor
          , shouldShowColor guessColor model.validation
          )
        , ( needsSelectionClass model
          , shouldShowNeedsSelection guessColor model.validation
          )
        ]
      ]


needsSelectionClass : Model -> String
needsSelectionClass model =
  "needs-selection-"
    ++ if model.attempts % 2 == 0 then "even" else "odd"


shouldShowColor : Maybe Color -> Validation -> Bool
shouldShowColor maybeColor validation =
  case maybeColor of
    Just _ ->
      True
    Nothing ->
      case validation of
        GuessIncomplete ->
          False
        Valid ->
          True


shouldShowNeedsSelection : Maybe Color -> Validation -> Bool
shouldShowNeedsSelection maybeColor validation =
  not <| shouldShowColor maybeColor validation


boundary : Svg Msg
boundary =
  Circle.unit 10
    [ Sattr.fill "white"
    ]


colors : List Color
colors =
  [ Red
  , Orange
  , Yellow
  , Green
  , Blue
  ]


colorToClass : Maybe Color -> String
colorToClass maybeColor =
  Maybe.map Code.colorToClass maybeColor
    |> Maybe.withDefault "empty"


selectableColors : Int -> List Color -> Svg Msg
selectableColors index colors =
  Svg.g [] <|
    [ base index <| List.head colors ] ++
      divisions index
        (List.length colors)
        (List.drop 1 colors)


base : Int -> Maybe Color -> Svg Msg
base index maybeColor =
  Circle.unit 15 <|
    case maybeColor of
      Just baseColor ->
        [ Sattr.class <| Code.colorToClass baseColor
        , Events.onClick <| GuessInput index baseColor
        ]
      Nothing ->
        []


divisions : Int -> Int -> List Color -> List (Svg Msg)
divisions index total colors =
  let
    extent = (toFloat <| List.length colors) / toFloat total
  in
    case List.head colors of
      Just wedgeColor ->
        [ wedge index extent wedgeColor ] ++
          divisions index total (List.drop 1 colors)
      Nothing ->
        []


wedge : Int -> Float -> Color -> Svg Msg
wedge index extent color =
  Wedge.vector extent
    [ Sattr.class <| Code.colorToClass color
    , Events.onClick <| GuessInput index color
    ]
