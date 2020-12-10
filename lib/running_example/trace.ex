defmodule TransformerTestSupport.RunningExample.Trace do
  use TransformerTestSupport.Drink.Me
  alias T.RunningExample.TraceServer
  alias T.SmartGet.Example

  # -----------Wrappers around functions--------------------------------------
  # Note that these return the values of the wrapped functions.

  def tio__(running, f) do
    stash = tio_enter(running)
    capture_assertion_failure(fn ->
      result = TraceServer.nested(fn -> f.(running) end)
      tio_exit(stash)
      result
    end)
  end

  def tio_enter(running) do
    example_name = example_name(running)
    workflow = example_workflow(running)
    TraceServer.accept("> Run #{cyan(example_name)} (#{workflow})")
    %{name: example_name}
  end

  defp tio_exit(stash) do
    TraceServer.accept(["< Run ", cyan(stash.name)])
    TraceServer.add_vertical_separation
  end
    
  def tli__(running, f, label) do
    say(label)
    TraceServer.nested(fn ->
      result = f.(running)
      unless result == :uninteresting_result,
        do: say(result, :result)
      result
    end)
  end
  
  def capture_assertion_failure(f) do
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

  # ----------------------------------------------------------------------------

  defp red(string), do: color(IO.ANSI.red(), string)
  defp cyan(string), do: color(IO.ANSI.cyan(), string)
  defp color(color, string), do: color <> string <> IO.ANSI.reset()

  defp example_name(running), do: inspect Example.name(running.example)
  defp example_workflow(running), do: inspect Example.workflow_name(running.example)
end
