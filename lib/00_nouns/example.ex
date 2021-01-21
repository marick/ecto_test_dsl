defmodule TransformerTestSupport.Nouns.Example do
  use TransformerTestSupport.Drink.Me
  use T.Drink.AssertionJuice
  import T.ModuleX
  
  @moduledoc """
  All that is known, across major modules, about the example datastructure.
  (The parser and `Run.RunningExample` have their own individual major-module-
  specific knowledge.)
  """

  getters :metadata, [:name, :workflow_name, :repo]

  private_getters :metadata, [:variant]

  def workflow_steps(example) do
    workflow_name = workflow_name(example)
    workflows = variant(example).workflows()
    
    step_list = 
      Map.get(workflows, workflow_name, :missing_workflow)

    # This should be a bug in one of the tests in tests, most likely using
    # the Trivial variant instead of one with actual steps.
    # Or the variant's validity checks are wrong.
    elaborate_refute(step_list == :missing_workflow,
      "Example #{inspect name(example)} seems to have an incorrect workflow name.",
      left: workflow_name, right: Map.keys(workflows))

    step_list
  end
  
end
