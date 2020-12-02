defmodule TransformerTestSupport.Types do
  defmacro een(pair_list) when is_list(pair_list) do
    [{example_name, module_name}] = pair_list
    quote do
      {unquote(example_name), unquote(module_name)}
    end
  end

  defmacro een(example_name) when is_atom(example_name) do
    quote do
      {unquote(example_name), __MODULE__}
    end
  end
end
