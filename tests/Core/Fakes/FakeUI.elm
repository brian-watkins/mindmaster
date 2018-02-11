module Core.Fakes.FakeUI exposing (..)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Core.Types exposing (GuessFeedback(..), Color, Code, GameState(..))

type Msg
  = PlayGuess
  | HandleFeedback GuessFeedback

type alias Model =
  { feedback : Maybe GuessFeedback
  }

defaultModel : Model
defaultModel =
  { feedback = Nothing }

update : Code -> ((GuessFeedback -> Msg) -> Code -> Cmd msg) -> Msg -> Model -> (Model, Cmd msg)
update code evaluateGuess msg model =
  case msg of
    PlayGuess ->
      ( model, evaluateGuess HandleFeedback code )
    HandleFeedback feedback ->
      ( { model | feedback = Just feedback }, Cmd.none )

view : GameState -> Model -> Html Msg
view _ model =
  Html.div [ Attr.id "submit-code", Events.onClick PlayGuess ] []
