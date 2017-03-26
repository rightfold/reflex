module Main
  ( start
  , invoke
  ) where

import Control.Monad.Aff (Aff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Prelude

type State = String

start :: ∀ eff. Aff eff State
start = pure "Hello, world!"

invoke :: ∀ eff. State -> Unit -> Aff (console :: CONSOLE | eff) Unit
invoke state _ = liftEff $ log state
