module Reflex.Actor
  ( ACTOR
  , Actor
  , startActor
  , invokeActor
  ) where

import Reflex.Config (ActorConfig)
import Reflex.Prelude

foreign import data ACTOR :: Effect

newtype Actor = Actor (∀ eff. Unit -> Aff (actor :: ACTOR | eff) Unit)

foreign import startActor
  :: ∀ eff
   . ActorConfig
  -> Aff (actor :: ACTOR | eff) Actor

invokeActor :: ∀ eff. Actor -> Unit -> Aff (actor :: ACTOR | eff) Unit
invokeActor (Actor a) = a
