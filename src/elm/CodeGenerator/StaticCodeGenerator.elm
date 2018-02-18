module CodeGenerator.StaticCodeGenerator exposing
  ( generator
  )

import Core.Command as Command


generator : List a -> (List a -> msg) -> Cmd msg
generator code tagger =
  Command.toCmd tagger code
