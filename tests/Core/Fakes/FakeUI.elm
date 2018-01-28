module Core.Fakes.FakeUI exposing (..)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Core.Types exposing (GuessFeedback(..), Color(..))

type Msg =
  PlayGuess

type alias Model =
  { feedback : Maybe GuessFeedback
  }

defaultModel : Model
defaultModel =
  { feedback = Nothing }

update : List Color -> (List Color -> GuessFeedback) -> Msg -> Model -> (Model, Cmd Msg)
update code playGuess msg model =
  case msg of
    PlayGuess ->
      ( { model | feedback = Just <| playGuess code }, Cmd.none )

view : Model -> Html Msg
view model =
  Html.div [ Attr.id "submit-code", Events.onClick PlayGuess ] []
