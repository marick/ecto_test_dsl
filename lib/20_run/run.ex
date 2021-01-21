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


  
  defp run_steps(running) do
    case running.script do
      [] ->
        running.history
      [step_name | rest] ->
        function =
          Function.capture(RunningExample.variant(running), step_name, 1)
        value =
          Trace.apply(function, running) |> Trace.as_nested_value(step_name)

        running
        |> Map.update!(:history, &(History.add(&1, step_name, value)))
        |> Map.put(:script, rest)
        |> run_steps
    end
  end

end
