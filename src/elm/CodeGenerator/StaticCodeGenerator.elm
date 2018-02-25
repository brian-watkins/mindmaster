module CodeGenerator.StaticCodeGenerator exposing
  ( generator
  )

import Util.Command as Command


generator : List a -> (List a -> msg) -> Cmd msg
generator code tagger =
  Command.toCmd tagger code
