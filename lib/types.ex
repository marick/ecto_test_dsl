defmodule TransformerTestSupport.Types do

  @moduledoc """
  These are constructors for everything I'm boldly treating as an
  abstract data type. All the manipulation functions are in submodules.
  That's probably a bad idea, but it hides the difference between constructors
  that are macros and ones that are true functions.

  Though having any macros at all (in order to capture __MODULE__) is pretty
  dubious.
  """
  
  defmacro een_t(pair_list) when is_list(pair_list) do
    [{example_name, module_name}] = pair_list
    quote do
      {unquote(example_name), unquote(module_name)}
    end
  end

  defmacro een_t(example_name) when is_atom(example_name) do
    quote do
      {unquote(example_name), __MODULE__}
    end
  end
end
