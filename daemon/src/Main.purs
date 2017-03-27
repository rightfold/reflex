module Main
  ( main
  ) where

import Control.Monad.Aff (runAff)
import Control.Monad.Eff.Console (CONSOLE, error)
import Control.Monad.Eff.Exception (EXCEPTION, message)
import Control.Parallel (parTraverse, parTraverse_)
import Network.ZMQ (ZMQ)
import Network.ZMQ as ZMQ
import Node.Encoding (Encoding(..))
import Node.FS (FS)
import Node.FS.Sync (readTextFile)
import Node.Process (PROCESS, argv, exit)
import Reflex.Actor (ACTOR, invokeActor, startActor)
import Reflex.Event (parseEvent)
import Reflex.Config (Config, parseConfig)
import Reflex.Prelude

type Effects eff =
  ( actor   :: ACTOR
  , console :: CONSOLE
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
  actors <- parTraverse startActor config.actors
  zmq <- ZMQ.defaultContext
  ZMQ.withSocket zmq \(socket :: ZMQ.Socket ZMQ.PULL) -> do
    ZMQ.bindSocket socket config.relay.address
    forever do
      message <- ZMQ.receive socket
      case parseEvent message of
        Left  err   -> liftEff $ error err
        Right event -> parTraverse_ (invokeActor `flip` event) actors

usage :: ∀ eff. Eff (Effects eff) Unit
usage = fatal "Usage: reflexd <config-path>"

fatal :: ∀ eff a. String -> Eff (Effects eff) a
fatal = (*>) <$> error <*> const (exit 1)
