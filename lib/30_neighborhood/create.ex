defmodule EctoTestDSL.Neighborhood.Create do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AndRun

  def from_an_een(%EEN{} = een, so_far) do
    unless_already_present(een, so_far, fn ->
      workflow_results = 
        een.module
        |> TestData.example(een.name)
        |> Run.example(previously: so_far)

      dependently_created = Keyword.get(workflow_results, :previously)
      {:ok, insert_result} = Keyword.get(workflow_results, :try_changeset_insertion)
      
      Map.put(dependently_created, een, insert_result)
    end)
  end
  
  # ----------------------------------------------------------------------------

  defp unless_already_present(extended_example_name, so_far, f) do 
    if Map.has_key?(so_far, extended_example_name), do: so_far, else: f.()
  end
end
