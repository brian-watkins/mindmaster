module Spec.Extra exposing
  ( equals
  , hasText
  , hasClass
  , expectElement
  )

import Spec exposing (..)
import Spec.Claim as Claim exposing (Claim, isStringContaining, isSomethingWhere)
import Spec.Markup as Markup exposing (HtmlElement)
import Spec.Observer as Observer exposing (Observer)


equals : a -> Claim a
equals =
  Claim.isEqual Debug.toString


hasText : String -> Claim HtmlElement
hasText text =
  Markup.text <| isStringContaining 1 text


expectElement : Claim a -> Observer model (Maybe a) -> Expectation model
expectElement claim observer =
  observer
    |> Observer.focus isSomethingWhere
    |> expect claim


hasClass : String -> Claim HtmlElement
hasClass className =
  Markup.attribute "class" <| isSomethingWhere <| isStringContaining 1 className
