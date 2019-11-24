module CodeGenerator.RandomCodeGenerator exposing
  ( generator
  )

import Random exposing (Generator)


type alias Randomizer a msg =
  (List a -> msg) -> Generator (List a) -> Cmd msg


generator : Randomizer a msg -> Int -> a -> List a -> (List a -> msg) -> Cmd msg
generator randomizer codeLength default items tagger =
  codeGenerator codeLength default items
    |> randomizer tagger


codeGenerator : Int -> a -> List a -> Generator (List a)
codeGenerator codeLength default items =
  List.length items
    |> Random.int 0
    |> Random.map (\num ->
      List.drop (num - 1) items
        |> List.head
        |> Maybe.withDefault default
    )
    |> Random.list codeLength
