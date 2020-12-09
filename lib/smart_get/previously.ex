defmodule TransformerTestSupport.SmartGet.Previously do
    
  @moduledoc """
  """

  def expand_in_list(list, previously) do
    for {name, value} <- list do
      case value do
        {:__previously_reference, extended_example_name, :primary_key} ->
          {name, Map.get(previously, extended_example_name).id}
        _ ->
          {name, value}
      end
    end
  end
end
