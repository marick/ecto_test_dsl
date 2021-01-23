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

  def workflow_script(example, opts) do
    stop = Keyword.get(opts, :stop_after, :"this should not ever be a step name")

    Example.workflow_steps(example)
    |> EnumX.take_until(&(&1 == stop))
  end


  
  defp run_steps(running_start) do
    running_start.script
    |> Enum.reduce(running_start, &run_step/2)
    |> Map.get(:history)
  end

  defp run_step([step_name | opts], running) do
    case opts do
      [uses: rest_args] -> 
        module = RunningExample.variant(running)
        value = apply(module, step_name, [running, rest_args])
        Map.update!(running, :history, &(History.add(&1, step_name, value)))
      _ ->
        flunk("`#{inspect [step_name, opts]}` has bad options. `uses` is required.")
    end
  end

  defp run_step(step_name, running) do
    run_step([step_name, uses: []], running)
  end
end
