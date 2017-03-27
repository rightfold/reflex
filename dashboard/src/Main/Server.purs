module Main.Server
  ( start
  , invoke
  ) where

import Control.Monad.Aff (Aff)
import Control.Monad.Eff.Class (liftEff)
import Data.Argonaut.Core (jsonEmptyObject, stringify)
import Data.Argonaut.Encode ((~>), (:=))
import Data.StrMap (StrMap)
import Network.WebSocket.Serve (Server, WEBSOCKET, broadcastString, newServer)
import Prelude

type Event =
  { origin  :: String
  , service :: String
  , value   :: Number
  , meta    :: StrMap String
  }

type State = Server

start :: ∀ eff. Aff (webSocket :: WEBSOCKET | eff) State
start = liftEff $ newServer {host: "0.0.0.0", port: 7756}

invoke :: ∀ eff. State -> Event -> Aff (webSocket :: WEBSOCKET | eff) Unit
invoke state event = liftEff $ broadcastString state (stringify event')
  where
  event' =
       "origin"  := event.origin
    ~> "service" := event.service
    ~> "value"   := event.value
    ~> "meta"    := event.meta
    ~> jsonEmptyObject
