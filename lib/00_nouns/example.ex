defmodule TransformerTestSupport.Nouns.Example do
  use TransformerTestSupport.Drink.Me
  import T.ModuleX
  
  @moduledoc """
  All that is known, across major modules, about the example datastructure.
  (The parser and `Run.RunningExample` have their own individual major-module-
  specific knowledge.)
  """

  getters :metadata, [:name, :workflow_name, :repo]
end
