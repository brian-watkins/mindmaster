module CodeGenerator.RandomCodeGenerator exposing
  ( generator
  )

import Random exposing (Generator)


generator : Int -> a -> List a -> (List a -> msg) -> Cmd msg
generator codeLength default items tagger =
  codeGenerator codeLength default items
    |> Random.generate tagger


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
