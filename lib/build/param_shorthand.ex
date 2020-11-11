defmodule TransformerTestSupport.Build.ParamShorthand do
  @moduledoc """
  This is a second pass of processing examples, following `Normalize`.
  The two passes could be consolidated. But let's hold off on that.
  """
  def build_time_expansion(new_pairs, existing_pairs) do
    Enum.reduce(new_pairs, existing_pairs, fn {new_name, new_example}, acc ->
      expanded = expand(new_example, :example, acc)
      [{new_name, expanded} | acc]
    end)
  end

  def expand(example, :example, existing_pairs) do
    example
    |> expand_interior(:params, existing_pairs)
  end

  def expand_interior(example, field, existing_pairs) do
    field_value = Map.get(example, field)
    case is_function(field_value) do
      true ->
        Map.put(example, field, field_value.(existing_pairs))
      false ->
        example
    end
  end
end
