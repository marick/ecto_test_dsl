defmodule TransformerTestSupport.RunningExample.Trace do
  alias TransformerTestSupport, as: T
  alias T.RunningExample.Trace
  alias T.RunningExample.TraceServer
  alias T.SmartGet.Example
  alias T.RunningExample


  # -----------Wrappers around blocks-------------------------------------------

  def tio__(running, f) do
    stash = Trace.tio_enter(running)
    Trace.capture_assertion_failure(fn ->
      result = TraceServer.nested(fn -> f.(running) end)
      Trace.tio_exit(stash)
      result
    end)
  end

  def tio_enter(running) do
    example_name = example_name(running)
    workflow = example_workflow(running)
    TraceServer.accept("> Run #{cyan(example_name)} (#{workflow})")
    %{name: example_name}
  end

  def tio_exit(stash) do
    TraceServer.accept(["< Run ", cyan(stash.name)])
    TraceServer.separate
  end
    
  def tli__(running, f, label) do
    Trace.say(label)
    TraceServer.nested(fn ->
      result = f.(running)
      unless result == :uninteresting_result,
        do: Trace.say(result, :result)
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

  def say(value) do
    TraceServer.accept(inspect(value))
    value
  end

  def say(value, label) do
    colorized = [IO.ANSI.green(), to_string(label), ": ", IO.ANSI.reset()]
    TraceServer.accept([colorized, inspect(value)])
    value
  end

  # ----------------------------------------------------------------------------

  defp red(string), do: color(IO.ANSI.red(), string)
  defp cyan(string), do: color(IO.ANSI.cyan(), string)
  defp color(color, string), do: color <> string <> IO.ANSI.reset()

  defp example_name(running), do: inspect Example.name(running.example)
  defp example_workflow(running), do: inspect Example.category_name(running.example)

  defp selector(caller_context) do
    [module | _] = caller_context.context_modules
    {fun, _} = caller_context.function
    quote do: {unquote(module), unquote(fun)}
  end
end
