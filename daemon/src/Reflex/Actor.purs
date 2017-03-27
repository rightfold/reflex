module Reflex.Actor
  ( ACTOR
  , Actor
  , startActor
  , invokeActor
  ) where

import Reflex.Config (ActorConfig)
import Reflex.Event (Event)
import Reflex.Prelude

foreign import data ACTOR :: Effect

newtype Actor = Actor (∀ eff. Event -> Aff (actor :: ACTOR | eff) Unit)

foreign import startActor
  :: ∀ eff
   . ActorConfig
  -> Aff (actor :: ACTOR | eff) Actor

invokeActor :: ∀ eff. Actor -> Event -> Aff (actor :: ACTOR | eff) Unit
invokeActor (Actor a) = a
