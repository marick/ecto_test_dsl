defmodule TransformerTestSupport.Impl.Like do
  @moduledoc """
  This is a second pass of processing examples, following `Normalize`.
  The two passes could be consolidated. But let's hold off on that.
  """
  def expand(new_pairs, :example_pairs, existing_pairs) do
    for {new_name, new_example} <- new_pairs do
      {new_name, expand(new_example, :example, existing_pairs)}
    end
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
