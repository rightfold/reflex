module Network.WebSocket.Serve
  ( WEBSOCKET

  , Server
  , newServer
  , clients

  , Client
  , sendString

  , broadcastString
  ) where

import Control.Monad.Eff (Eff)
import Data.Foldable (traverse_)
import Prelude

--------------------------------------------------------------------------------

foreign import data WEBSOCKET :: Effect

--------------------------------------------------------------------------------

foreign import data Server :: Type

foreign import newServer
  :: ∀ eff
   . {host :: String, port :: Int}
  -> Eff (webSocket :: WEBSOCKET | eff) Server

foreign import clients
  :: ∀ eff
   . Server
  -> Eff (webSocket :: WEBSOCKET | eff) (Array Client)

--------------------------------------------------------------------------------

foreign import data Client :: Type

foreign import sendString
  :: ∀ eff
   . Client
  -> String
  -> Eff (webSocket :: WEBSOCKET | eff) Unit

--------------------------------------------------------------------------------

broadcastString
  :: ∀ eff
   . Server
  -> String
  -> Eff (webSocket :: WEBSOCKET | eff) Unit
broadcastString s m = traverse_ (sendString `flip` m) =<< clients s
