module UI.Views.Feedback exposing
  ( view
  )

import Core.Types exposing (GuessFeedback(..))
import UI.Types exposing (..)
import UI.Vectors.Circle as Circle
import UI.Vectors.Arc as Arc
import Html exposing (Html)
import Html.Attributes as Attr
import Svg exposing (Svg)
import Svg.Attributes as SvgAttr
import Array exposing (Array)


type alias Clue =
  { class : Maybe String
  , x : Float
  , y : Float
  }


view : Int -> GuessFeedback -> Html Msg
view codeLength feedback =
    Html.div [ Attr.class "clue" ]
    [ Svg.svg [ SvgAttr.viewBox "0 0 30 30"] <|
        ( clueList codeLength feedback
            |> positioned (emptyClues codeLength)
            |> List.map clueElement
        )
    ]


clueElement : Clue -> Svg Msg
clueElement clue =
  Circle.vector { x = clue.x, y = clue.y, radius = 5 }
    [ SvgAttr.class (Maybe.withDefault "empty" clue.class)
    , Attr.attribute "data-clue-element" ""
    ]


clueList : Int -> GuessFeedback -> List String
clueList codeLength feedback =
  case feedback of
    Wrong clue ->
      List.append
        (List.repeat clue.positions "black")
        (List.repeat (clue.colors - clue.positions) "white")
    Correct ->
      List.repeat codeLength "black"


positioned : List Clue -> List String -> List Clue
positioned positionedClues clueClasses =
  case clueClasses of
    [] ->
      positionedClues
    x :: xs ->
      case positionedClues of
        [] ->
          []
        clue :: clues ->
          { clue | class = Just x } ::
            positioned clues xs


emptyClues : Int -> List Clue
emptyClues total =
  List.range 0 (total - 1)
    |> List.map toFloat
    |> List.map (\d -> d / toFloat total)
    |> List.map emptyClue


emptyClue : Float -> Clue
emptyClue extent =
  let
    arc = Arc.with 10 extent
  in
    { class = Nothing
    , x = 15 + arc.dx
    , y = 5 + arc.dy
    }
