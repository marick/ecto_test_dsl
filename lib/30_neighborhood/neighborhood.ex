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
    

  
end
