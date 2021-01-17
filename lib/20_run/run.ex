defmodule TransformerTestSupport.Run do
  use TransformerTestSupport.Drink.Me
  use T.Drink.AndRun
  use T.Drink.AssertionJuice

  def example(example, opts \\ []) do
    running = RunningExample.from(example,
      script: workflow_script(example, opts),
      history: History.new(example, opts)
    )

    Trace.apply(&run_steps/1, running) |> Trace.in_out
  end

  defp run_steps(running) do
    case running.script do
      [] ->
        running.history
      [{step_name, function} | rest] ->
        value = 
          Trace.apply(function, running) |> Trace.as_nested_value(step_name)

        running
        |> Map.update!(:history, &(History.add(&1, step_name, value)))
        |> Map.put(:script, rest)
        |> run_steps
    end
  end

  def workflow_script(example, opts) do
    stop = Keyword.get(opts, :stop_after, :"this should not ever be a step name")

    attach_functions = fn step_names ->
      step_functions = step_functions(example)
      for name <- step_names, do: {name, step_functions[name]}
    end

    step_list!(example)
    |> EnumX.take_until(&(&1 == stop))
    |> attach_functions.()
  end


  defp step_list!(example) do
    workflows = workflows(example)
    workflow_name = workflow_name(example)
    
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

  defp metadata!(example, field),
    do: Map.fetch!(example.metadata, field)
  defp workflows(example), do: metadata!(example, :workflows)
  defp workflow_name(example), do: metadata!(example, :workflow_name)
  def step_functions(example), do: metadata!(example, :steps)
  def name(example), do: metadata!(example, :name)
  
end
