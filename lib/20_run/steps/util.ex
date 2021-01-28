defmodule EctoTestDSL.Run.Steps.Util do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AssertionJuice
  use EctoTestDSL.Drink.AndRun
  
  def context(name, message),
    do: "Example `#{inspect name}`: #{message}"

  def identify_example(name) do
    fn message -> context(name, message) end
  end

  # ----------------------------------------------------------------------------
  defmacro from(running, use: keys) do 
    varlist = for key <- keys,
      do: Macro.var(key, nil)
    calls = for key <- keys,
      do: field_access(key, running)
    emit(varlist, calls)
  end

  defmacro from_history(running, kws) do
    varlist = for {var_name, _step_name} <- kws,
      do: Macro.var(var_name, nil)
    calls = for {_var_name, step_name} <- kws,
      do: history_access(step_name, running)
    emit(varlist, calls)
  end

  defp field_access(key, running) do
    quote do
      mockable(RunningExample).unquote(key)(unquote(running))
    end
  end

  defp history_access(step_name, running) do
    quote do 
      mockable(RunningExample).step_value!(unquote(running), unquote(step_name))
    end
  end

  defp emit(varlist, calls) do
    quote do: {unquote_splicing(varlist)} = {unquote_splicing(calls)}
  end
end
