module Main
  ( main
  ) where

import Control.Monad.Eff.Console (CONSOLE, error)
import Control.Monad.Eff.Exception (EXCEPTION)
import Node.Encoding (Encoding(..))
import Node.FS (FS)
import Node.FS.Sync (readTextFile)
import Node.Process (PROCESS, argv, exit)
import Reflex.Config (Config, parseConfig)
import Reflex.Prelude

type Effects eff =
  ( console :: CONSOLE
  , err     :: EXCEPTION
  , fs      :: FS
  , process :: PROCESS
  | eff
  )

main :: ∀ eff. Eff (Effects eff) Unit
main = argv >>= case _ of
  [_, _, configPath] -> do
    configFile <- readTextFile UTF8 configPath
    let config = parseConfig configFile
    either fatal main' config
  _ -> usage *> exit 1

main' :: ∀ eff. Config -> Eff (Effects eff) Unit
main' _ = pure unit

usage :: ∀ eff. Eff (Effects eff) Unit
usage = fatal "Usage: reflexd <config-path>"

fatal :: ∀ eff a. String -> Eff (Effects eff) a
fatal = (*>) <$> error <*> const (exit 1)
