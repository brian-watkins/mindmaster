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
  , guesses : List Code
  }

defaultModel : List Code -> Model
defaultModel guesses =
  { feedback = Nothing
  , guesses = guesses
  }

update : ViewDependencies Msg msg -> Msg -> Model -> (Model, Cmd msg)
update dependencies msg model =
  case msg of
    PlayGuess ->
      case List.head model.guesses of
        Just guess ->
          ( { model | guesses = List.drop 1 model.guesses }
          , dependencies.guessEvaluator HandleFeedback guess
          )
        Nothing ->
          ( model, Cmd.none )
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
