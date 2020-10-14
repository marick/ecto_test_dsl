defmodule TransformerTestSupport.Impl.SmartGet.Changeset do
  alias TransformerTestSupport.Impl.SmartGet
    
  @moduledoc """
  """

  def get(test_data, example_name) do
    example = SmartGet.example(test_data, example_name)

    Map.get(example, :changeset, [])
    |> add_validity_check(example.category)
  end

  defp add_validity_check(changeset, category) do
    if category == :validation_failure,
      do:   [:invalid | changeset],
      else: [  :valid | changeset]
  end
end
