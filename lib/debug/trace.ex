defmodule TransformerTestSupport.Trace do
  use TransformerTestSupport.Drink.Me
  alias T.TraceServer
  alias T.SmartGet.Example

  # -----Functions that can be called anywhere----------------------------------
  # Note that these do not return values.

  def say(value) do
    TraceServer.accept(inspect(value))
    :no_meaningful_value
  end

  def say(value, label) do
    colorized = [IO.ANSI.green(), to_string(label), ": ", IO.ANSI.reset()]
    TraceServer.accept([colorized, inspect(value)])
    :no_meaningful_value
  end

  # -----------Wrappers around functions--------------------------------------

  # The conceit here is that you "Trace.apply" a function to a value,
  # then pass the "result" to Trace.in_out or Trace.value_of.
  #
  #     Trace.apply(&run_steps/1, running) |> Trace.in_out
  # 
  # 
  # In fact, Trace.apply just wraps its argument, and the end of the
  # pipeline in fact calls the function.
  #
  # Note that these return the values of the wrapped functions.

  def apply(f, running), do: {f, running}

  def in_out({f, running}) do
    stash = trace_enter(running)
    capture_assertion_failure(fn ->
      result = TraceServer.nested(fn -> f.(running) end)
      trace_exit(stash)
      result
    end)
  end

  def as_nested_value({f, running}, label) do
    say(label)
    TraceServer.nested(fn ->
      result = f.(running)
      unless result == :uninteresting_result,
        do: say(result, :result)
      result
    end)
  end

  defp trace_enter(running) do
    example_name = example_name(running)
    workflow = example_workflow(running)
    TraceServer.accept("> Run #{cyan(example_name)} (#{workflow})")
    %{name: example_name}
  end

  defp trace_exit(stash) do
    TraceServer.accept(["< Run ", cyan(stash.name)])
    TraceServer.add_vertical_separation
  end
    
  defp capture_assertion_failure(f) do
    try do
      f.()
    rescue
      ex in ExUnit.AssertionError ->
        if TraceServer.at_top_level? do
          TraceServer.accept(red("!!assertion error!!"))
          TraceServer.nested(fn ->
            TraceServer.accept(ex.message)
          end)
        end
        reraise ex, __STACKTRACE__
    end
  end

  # ----------------------------------------------------------------------------

  defp red(string), do: color(IO.ANSI.red(), string)
  defp cyan(string), do: color(IO.ANSI.cyan(), string)
  defp color(color, string), do: color <> string <> IO.ANSI.reset()

  defp example_name(running), do: inspect Example.name(running.example)
  defp example_workflow(running), do: inspect Example.workflow_name(running.example)
end
