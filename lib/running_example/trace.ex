defmodule TransformerTestSupport.RunningExample.Trace do
  alias TransformerTestSupport, as: T
  alias T.RunningExample.Trace
  alias T.RunningExample.TraceServer
  alias T.SmartGet.Example
  alias T.RunningExample

  defmacro tio__(running, block) do
    selector = selector(__CALLER__)
    quote do
      r = unquote(running)
      stash = Trace.enter(unquote(selector), r)

      Trace.capture_assertion_failure(fn -> 
        result =
          TraceServer.nested(fn ->
            r |> unquote(block)
          end)
        Trace.exit(unquote(selector), result, stash)
        result
      end)
    end
  end

  defmacro tli__(running, block, label) do
    quote do
      Trace.say(unquote(label))
      TraceServer.nested(fn ->
        result = unquote(running) |> unquote(block)
        unless result == :uninteresting_result,
          do: Trace.say(result, :result)
      end)
    end
  end
                 
  def capture_assertion_failure(f) do
    try do
      f.()
    rescue
      ex in ExUnit.AssertionError ->
        if TraceServer.at_top_level? do 
          TraceServer.accept("!!assertion error!!")
          TraceServer.nested(fn ->
            TraceServer.accept(ex.message)
          end)
        end
        reraise ex, __STACKTRACE__
    end
  end


  # defmacro t__(value) do
  #   selector = selector(__CALLER__)
  #   quote do
  #     v = unquote(value)
  #     Trace.say(unquote(selector), v)
  #   end
  # end
    
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

  def enter({RunningExample, :run}, running) do
    example_name = example_name(running)
    workflow = example_workflow(running)
    TraceServer.accept("> Run #{cyan(example_name)} (#{workflow})")
    %{name: example_name}
  end

  def enter(_, _), do: :ok

  # ----------------------------------------------------------------------------
  def exit({_, :run}, _result, stash) do
    TraceServer.accept(["< Run ", cyan(stash.name)])
    TraceServer.separate
  end

  def exit({RunningExample, :run_steps}, result, _stash) do
    TraceServer.accept(inspect result)
    :ok
  end

  def exit(_, _, _), do: :ok


  defp cyan(string), do: color(IO.ANSI.cyan(), string)
  defp color(color, string), do: color <> string <> IO.ANSI.reset()

# {{:., [line: 21],
#   [
#     {:__aliases__,
#      [counter: {TransformerTestSupport.RunningExample, 24}, line: 21], [:Map]},
#     :get
#   ]}, [line: 21], [5]}


#      unquote(value) |> unquote(block)
# {:run_steps, [line: 21], nil}


# {:run_steps, [line: 21], []}


# {:&, [line: 21],
#  [
#    {{:., [line: 21], [{:+, [line: 21], [{:&, [line: 21], [1]}, 2]}]},
#     [line: 21], []}
#  ]}


 
  defp example_name(running), do: inspect Example.name(running.example)
  defp example_workflow(running), do: inspect Example.category_name(running.example)


  defp selector(caller_context) do 
    [module | _] = caller_context.context_modules
    {fun, _} = caller_context.function
    quote do: {unquote(module), unquote(fun)}
  end
end
