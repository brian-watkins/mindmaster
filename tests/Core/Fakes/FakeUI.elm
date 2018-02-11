module Core.Fakes.FakeUI exposing (..)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Core.Types exposing (ViewDependencies, GuessFeedback(..), Color, Code, GameState(..))

type Msg
  = PlayGuess
  | HandleFeedback GuessFeedback
  | RestartGame

type alias Model =
  { feedback : Maybe GuessFeedback
  }

defaultModel : Model
defaultModel =
  { feedback = Nothing }

update : Code -> ViewDependencies Msg msg -> Msg -> Model -> (Model, Cmd msg)
update code dependencies msg model =
  case msg of
    PlayGuess ->
      ( model, dependencies.guessEvaluator HandleFeedback code )
    HandleFeedback feedback ->
      ( { model | feedback = Just feedback }, Cmd.none )
    RestartGame ->
      ( model, dependencies.restartGameCommand )

view : GameState -> Model -> Html Msg
view _ model =
  Html.div []
  [ Html.div [ Attr.id "submit-code", Events.onClick PlayGuess ] []
  , Html.div [ Attr.id "restart-game", Events.onClick RestartGame ] []
  ]
