defmodule EctoTestDSL.Neighborhood do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AndRun

  defmodule Value do
    defstruct [:params, :changeset, :inserted]

    def inserted(value), do: %__MODULE__{inserted: value}

    def from_workflow_results(results) do 
      {:ok, insert_result} = Keyword.get(results, :try_changeset_insertion)

      inserted(insert_result)
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
    
  def from_an_een(%EEN{} = een, so_far) do
    unless_already_present(een, so_far, fn ->
      workflow_results = 
        een.module
        |> TestData.example(een.name)
        |> Run.example(repo_setup: so_far)

      dependently_created = Keyword.get(workflow_results, :repo_setup)
      value = Neighborhood.Value.from_workflow_results(workflow_results)

      Map.put(dependently_created, een, value)
    end)
  end
  
  # ----------------------------------------------------------------------------

  defp unless_already_present(extended_example_name, so_far, f) do 
    if Map.has_key?(so_far, extended_example_name), do: so_far, else: f.()
  end

  
end
