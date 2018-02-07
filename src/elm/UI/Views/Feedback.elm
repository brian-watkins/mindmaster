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


view : GuessFeedback -> Html Msg
view feedback =
    Html.div [ Attr.class "clue" ]
    [ Svg.svg [ SvgAttr.viewBox "0 0 30 30"] <|
        ( clueList feedback
            |> positioned emptyClues
            |> List.map clueElement
        )
    ]


clueElement : Clue -> Svg Msg
clueElement clue =
  Circle.vector { x = clue.x, y = clue.y, radius = 5 }
    [ SvgAttr.class (Maybe.withDefault "empty" clue.class)
    , Attr.attribute "data-clue-element" ""
    ]


clueList : GuessFeedback -> List String
clueList feedback =
  case feedback of
    Wrong clue ->
      List.append
        (List.repeat clue.positions "black")
        (List.repeat (clue.colors - clue.positions) "white")
    Correct ->
      List.repeat 5 "black"


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


emptyClues : List Clue
emptyClues =
  [ emptyClue 0.6
  , emptyClue 0.4
  , emptyClue 0.8
  , emptyClue 0.2
  , emptyClue 0.0
  ]


emptyClue : Float -> Clue
emptyClue extent =
  let
    arc = Arc.with 10 extent
  in
    { class = Nothing
    , x = 15 + arc.dx
    , y = 5 + arc.dy
    }
