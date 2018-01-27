module RandomCodeGenerator exposing
  ( generate
  )

import Random exposing (Generator)

generate : a -> List a -> Int -> (List a -> msg) -> Cmd msg
generate default items positions tagger =
  codeGenerator default items positions
    |> Random.generate tagger

codeGenerator : a -> List a -> Int -> Generator (List a)
codeGenerator default items positions =
  List.length items
    |> Random.int 0
    |> Random.map (\num ->
      List.drop (num - 1) items
        |> List.head
        |> Maybe.withDefault default
    )
    |> Random.list positions
