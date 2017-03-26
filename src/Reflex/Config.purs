module Reflex.Config
  ( Config
  , RelayConfig
  , ActorConfig
  , parseConfig
  ) where

import Data.Argonaut.Decode ((.?), decodeJson)
import Data.Argonaut.Parser (jsonParser)
import Reflex.Prelude

type Config =
  { relay  :: RelayConfig
  , actors :: List ActorConfig
  }

type RelayConfig =
  { address :: String
  }

type ActorConfig =
  { path :: String
  }

parseConfig :: String -> Either String Config
parseConfig = jsonParser >=> decodeJson >=> config
  where
  config j =
    {relay: _, actors: _}
    <$> (relayConfig =<< j .? "relay")
    <*> (traverse actorConfig =<< j .? "actors")

  relayConfig j =
    {address: _}
    <$> j .? "address"

  actorConfig j =
    {path: _}
    <$> j .? "path"
