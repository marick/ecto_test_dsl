defmodule TransformerTestSupport.RunningExample.Trace do
  alias TransformerTestSupport, as: T
  alias T.RunningExample.Trace
  alias T.RunningExample.TraceServer
  alias T.SmartGet.Example
  alias T.RunningExample

  defmacro ti__(running, block) do
    selector = selector(__CALLER__)
    quote do
      r = unquote(running)
      stash = Trace.enter(unquote(selector), r)

      try do
        result = TraceServer.nested(fn -> r |> unquote(block) end)
        Trace.exit(unquote(selector), result, stash)
        result
      rescue
        ex in ExUnit.AssertionError ->
          TraceServer.accept(["!! assertion error: ", ex.message])
          reraise ex, __STACKTRACE__
      end
    end   
  end

  defmacro ti__(running, block, label) do
    quote do
      TraceServer.accept(["+ ", inspect(unquote(label))])
      TraceServer.nested(fn -> 
        ti__(unquote(running), unquote(block))
      end)
    end
  end
                 

  # defmacro t__(value) do
  #   selector = selector(__CALLER__)
  #   quote do
  #     v = unquote(value)
  #     Trace.say(unquote(selector), v)
  #   end
  # end
    
  def say({RunningExample, :run_steps}, value) do
    TraceServer.accept(["+ ", inspect(value)])
  end

  # ----------------------------------------------------------------------------

  def enter({RunningExample, :run}, running) do
    example_name = example_name(running)
    workflow = example_workflow(running)
    TraceServer.accept("> Make #{example_name} (#{workflow})")
    %{name: example_name}
  end

  def enter(_, _), do: :ok

  # ----------------------------------------------------------------------------
  def exit({_, :run}, _result, stash) do
    TraceServer.accept("< Make #{stash.name}")
    TraceServer.separate
  end

  def exit({RunningExample, :run_steps}, result, _stash) do
    TraceServer.accept(inspect result)
    :ok
  end

  def exit(_, _, _), do: :ok
  

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
