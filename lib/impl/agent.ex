defmodule TransformerTestSupport.Impl.Agent do
  use Agent
  alias DeepMerge

  def start(),
    do: Agent.start_link(fn -> %{} end, name: __MODULE__)

  @doc """
  Lazy getter that triggers the creation of the data contained in `param_module`.
  """
  def test_data(param_module) do 
    case get(param_module) do
      nil -> 
        param_module.create_test_data()
        get(param_module)
      retval ->
        retval
    end
  end

  defp get(param_module), 
    do: Agent.get(__MODULE__, &(Map.get(&1, param_module)))

  # Initial creation functions

  @doc """
  Must be the first function called.
  """
  def start_test_data(param_module, value),
    do: update_with &(Map.put(&1, param_module, value))

  def deep_merge(param_module, mergeable),
    do: update_with &(DeepMerge.deep_merge(&1, %{param_module => mergeable}))

  defp update_with(f), do: Agent.update(__MODULE__, f)
end
