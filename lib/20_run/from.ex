defmodule EctoTestDSL.Run.From do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.Assertively
  use EctoTestDSL.Drink.AndRun
  
  defmacro from(running, use: keys) do
    assert_existence(keys, 1)
    varlist = Enum.map(keys, &one_var/1)    
    calls = Enum.map(keys, &(field_access(&1, running)))
    emit(varlist, calls)
  end

  defmacro from_history(running, kws) do
    varlist = Enum.map(kws, &one_var/1)
    calls = Enum.map(kws, &(history_access &1, running))
    emit(varlist, calls)
  end

  # ----------------------------------------------------------------------------
  defp one_var({var_name, _step_name}), do: Macro.var(var_name, nil)
  defp one_var( var_name),              do: Macro.var(var_name, nil)

  defp assert_existence(names, of_arity) do
    relevant = 
      RunningExample.__info__(:functions)
      |> Enum.filter(fn {_, arity} -> arity == of_arity end)
      |> Enum.map(fn {name, _} -> name end)
      |> MapSet.new

    extras = MapSet.difference(MapSet.new(names), relevant)
    unless Enum.empty?(extras) do
      raise "Unknown getters: #{inspect Enum.into(extras, [])}"
    end
  end
  
  defp field_access(key, running) do
    quote do: mockable(RunningExample).unquote(key)(unquote(running))
  end

  defp history_access({_var_name, step_name}, running),
    do: history_access(step_name, running)

  defp history_access(step_name, running) do
    quote do 
      mockable(RunningExample).step_value!(unquote(running), unquote(step_name))
    end
  end

  defp emit(varlist, calls) do
    quote do: {unquote_splicing(varlist)} = {unquote_splicing(calls)}
  end
end
