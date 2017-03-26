module Main
  ( main
  ) where

import Control.Monad.Aff (runAff)
import Control.Monad.Eff.Console (CONSOLE, error, log)
import Control.Monad.Eff.Exception (EXCEPTION, message)
import Data.ByteString (fromUTF8)
import Network.ZMQ (ZMQ)
import Network.ZMQ as ZMQ
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
  , zmq     :: ZMQ
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
main' config = void $ runAff (fatal <<< message) (const (pure unit)) do
  zmq <- ZMQ.defaultContext
  ZMQ.withSocket zmq \(socket :: ZMQ.Socket ZMQ.PULL) -> do
    ZMQ.bindSocket socket config.relay.address
    forever do
      message <- ZMQ.receive socket
      liftEff <<< log <<< show <<< map fromUTF8 $ message

usage :: ∀ eff. Eff (Effects eff) Unit
usage = fatal "Usage: reflexd <config-path>"

fatal :: ∀ eff a. String -> Eff (Effects eff) a
fatal = (*>) <$> error <*> const (exit 1)
