defmodule EctoTestDSL.Neighborhood do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AndRun

  defmodule Value do
    defstruct [:params, :changeset, :inserted]

    def inserted(value), do: %__MODULE__{inserted: value}
    def params(value), do: %__MODULE__{params: value}

    def from_workflow_results(results) do
      schema_module = Keyword.get(results, :example).metadata.module_under_test
      Enum.reduce(results, %__MODULE__{}, fn {name, value}, acc ->
        cond do 
          is_struct(value, schema_module) && acc.inserted == nil ->
            %{acc | inserted: value}
          name == :params ->
            %{acc | params: value}
          is_struct(value, Ecto.Changeset) -> 
            %{acc | changeset: value}
          true ->
            acc
        end
      end)
    end
  end

  def fetch!(neighborhood, een, value_type) do
    neighborhood
    |> MapX.fetch!(een, &Messages.missing_een/1)
    |> Map.get(value_type)
  end

  def augment(neighborhood, eens) do
    Enum.reduce(eens, neighborhood, &from_an_een/2)
  end

  # ----------------------------------------------------------------------------
    
  defp from_an_een(%EEN{} = een, so_far) do
    unless_already_present(een, so_far, fn ->
      workflow_results = 
        een.module
        |> TestData.example(een.name)
        |> Run.example(repo_setup: so_far)

      dependently_created = Keyword.get(workflow_results, :repo_setup)
      value = Value.from_workflow_results(workflow_results)

      Map.put(dependently_created, een, value)
    end)
  end
  
  defp unless_already_present(extended_example_name, so_far, f) do 
    if Map.has_key?(so_far, extended_example_name), do: so_far, else: f.()
  end
end
