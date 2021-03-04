defmodule EctoTestDSL.Nouns.Example do
  use EctoTestDSL.Drink.Me
  use T.Drink.Assertively
  import T.ModuleX
  
  @moduledoc """
  All that is known, across major modules, about the example datastructure.
  (The parser and `Run.RunningExample` have their own individual major-module-
  specific knowledge.)
  """

  getters :metadata, [:name, :workflow_name, :repo, :run, :examples_module]

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

  def run_decision(example, desired) do
    context = Keyword.get(desired, :run) 
    example_is = Map.get(example, :run) || :for_value_or_automatic

    case {context, example_is} do
      {:automatic_only, :for_value} -> :skip_because_only_for_value
      {:automatic_only, :skip} -> :user_skip
      {:for_value,      :skip} ->
        message = """
        You are running `#{inspect name(example)}` for its value
        (within a test or at the repl) but it's marked `:skip`.
        """
        flunk(message)
      _ -> :run
    end
  end
  
end
