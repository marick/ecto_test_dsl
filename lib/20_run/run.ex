defmodule EctoTestDSL.Run do
  use EctoTestDSL.Drink.Me
  use T.Drink.AndRun
  use T.Drink.Assertively
  alias T.TraceServer
  alias T.Nouns.Example

  def example(example, opts \\ []) do
    running = RunningExample.from(example,
      script: workflow_script(example, opts),
      history: History.new(example, opts)
    )

    Trace.apply(&run_steps/1, [running])
  end

  # ----------------------------------------------------------------------------
  @trace_server_translations %{
    prefix: :prefix,
    trace: :emitting?,
    max_level: :max_level
  }

  def check(example, opts) do
    {trace_server_opts, other_opts} =
      KeywordX.split_and_translate_keys(opts, @trace_server_translations)
    try do
      TraceServer.update(trace_server_opts)
      run_if_allowed(example, other_opts)
    after
      TraceServer.reset
    end
  end
  
  defp run_if_allowed(example, opts) do
    case T.Nouns.Example.run_decision(example, opts) do
      :run -> 
        T.Run.Sandbox.start(example)
        T.Run.example(example, opts)
      :skip_because_only_for_value ->
        :silently_skipped
      :user_skip ->
        IO.puts "\nskipping #{inspect Example.examples_module(example)}.#{Example.name(example)}"
    end
  end

  # ----------------------------------------------------------------------------
  defp workflow_script(example, opts) do
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
        value = apply_or_flunk(module, step_name, [running, rest_args])
        Map.update!(running, :history, &(History.add(&1, step_name, value)))
      _ ->
        flunk("`#{inspect [step_name, opts]}` has bad options. `uses` is required.")
    end
  end

  defp run_step(step_name, running) do
    run_step([step_name, uses: []], running)
  end

  defp apply_or_flunk(module, step_name, args) do 
    unless function_exported?(module, step_name, length(args)) do
      missing = "`#{to_string step_name}/#{inspect length(args)}`"
      flunk """
            Variant is missing step #{missing}".
            Did you leave it out of the list of steps (typically in `defsteps`)?
            """
    end
    Trace.apply(module, step_name, args)
  end
end
