module Reflex.Dashboard.Client.Monitor.UI
  ( Query
  , Input
  , Output

  , ui
  ) where

import Halogen.Component (Component, ComponentDSL, ComponentHTML, component)
import Halogen.HTML (HTML)
import Halogen.HTML as H
import Reflex.Dashboard.Filter (Filter, displayFilter)
import Reflex.Dashboard.Prelude

--------------------------------------------------------------------------------

data State   = State Filter
data Query a
  = Initialize a
  | SetFilter Filter a
type Input   = Filter
type Output  = Void

stateFilter :: Lens' State Filter
stateFilter = lens get set
  where get (State f) = f
        set (State _) f = State f

--------------------------------------------------------------------------------

ui :: ∀ m. Component HTML Query Input Output m
ui = component {initialState, render, eval, receiver}

initialState :: Input -> State
initialState = State

render :: State -> ComponentHTML Query
render s =
  H.div []
    [ H.text $ displayFilter (s ^. stateFilter)
    ]

eval :: ∀ m. Query ~> ComponentDSL State Query Output m
eval (Initialize next) = pure next
eval (SetFilter filter next) = do
  stateFilter .= filter
  pure next

receiver :: Input -> Maybe (Query Unit)
receiver = Just <<< SetFilter `flip` unit
