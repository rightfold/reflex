module Reflex.Dashboard.Filter
  ( Filter
  , FilterF(..)
  , runFilter
  , displayFilter
  , displayFilter'
  ) where

import Reflex.Dashboard.Prelude

type Filter = Mu FilterF

data FilterF a
  = Not a
  | Conj a a
  | Disj a a
  | Host String
  | Service String

derive instance functorFilterF :: Functor FilterF

runFilter :: ∀ r. Filter -> {host :: String, service :: String | r} -> Boolean
runFilter = flip \event -> cata case _ of
  Not a     -> not a
  Conj a b  -> a && b
  Disj a b  -> a || b
  Host h    -> h == event.host
  Service s -> s == event.service

-- | Display a filter for human consumption.
displayFilter :: Filter -> String
displayFilter (In (Conj (In (Host h)) (In (Service s)))) =
  show s <> " @ " <> show h
displayFilter o = displayFilter' o

-- | Display a filter for human consumption, not special-casing common filters.
displayFilter' :: Filter -> String
displayFilter' = cata case _ of
  Not a     -> "¬" <> a
  Conj a b  -> "(" <> a <> " ∧ " <> b <> ")"
  Disj a b  -> "(" <> a <> " ∨ " <> b <> ")"
  Host h    -> "(host = " <> show h <> ")"
  Service s -> "(service = " <> show s <> ")"
