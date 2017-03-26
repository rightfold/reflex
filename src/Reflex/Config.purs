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
  { host :: String
  , port :: Int
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
    {host: _, port: _}
    <$> j .? "host"
    <*> j .? "port"

  actorConfig j =
    {path: _}
    <$> j .? "path"
