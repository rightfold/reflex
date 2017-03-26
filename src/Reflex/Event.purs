module Reflex.Event
  ( Event
  , parseEvent
  ) where

import Data.Argonaut.Decode ((.?), decodeJson)
import Data.Argonaut.Parser (jsonParser)
import Data.ByteString (ByteString, fromUTF8, pack)
import Data.StrMap (StrMap)
import Reflex.Prelude

type Event =
  { origin  :: String
  , service :: String
  , value   :: Number
  , meta    :: StrMap String
  }

parseEvent :: Array ByteString -> Either String Event
parseEvent [versionB, payloadB]
  | versionB == pack [0, 0, 0, 1] = parseEventV1 payloadB
  | otherwise = Left "Unsupported version"
parseEvent _ = Left "Expected two parts"

parseEventV1 :: ByteString -> Either String Event
parseEventV1 = fromUTF8 >>> jsonParser >=> decodeJson >=> event
  where
  event j =
    {origin: _, service: _, value: _, meta: _}
    <$> j .? "origin"
    <*> j .? "service"
    <*> j .? "value"
    <*> j .? "meta"
