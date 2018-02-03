module UI.Views.Feedback exposing
  ( view
  )

import Core.Types exposing (GuessFeedback(..))
import UI.Types exposing (..)
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
    [ Svg.svg [ SvgAttr.viewBox "0 0 34 34"] <|
        ( clueList feedback
            |> positioned emptyClues 0
            |> List.map clueElement
        )
    ]


clueElement : Clue -> Svg Msg
clueElement clue =
  Svg.circle
    [ SvgAttr.cx <| toString clue.x
    , SvgAttr.cy <| toString clue.y
    , SvgAttr.r "5"
    , SvgAttr.class (Maybe.withDefault "empty" clue.class)
    , Attr.attribute "data-clue-element" ""
    ] []


clueList : GuessFeedback -> List String
clueList feedback =
  case feedback of
    Wrong clue ->
      List.append
        (List.repeat clue.positions "black")
        (List.repeat (clue.colors - clue.positions) "white")
    Correct ->
      List.repeat 5 "black"


positioned : Array Clue -> Int -> List String -> List Clue
positioned positionedClues offset clueClasses =
  case clueClasses of
    [] ->
      Array.toList positionedClues
    x :: xs ->
      let
        clue =
          Array.get offset positionedClues
            |> Maybe.withDefault (emptyClue 0 0)
      in
        positioned (Array.set offset { clue | class = Just x } positionedClues) (offset + 1) xs


emptyClues : Array Clue
emptyClues =
  Array.fromList
    [ emptyClue 11.25 26
    , emptyClue 22.75 26
    , emptyClue 8 15
    , emptyClue 26 15
    , emptyClue 17 7
    ]


emptyClue : Float -> Float -> Clue
emptyClue x y =
  { class = Nothing
  , x = x
  , y = y
  }
