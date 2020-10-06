defmodule TransformerTestSupport.Impl.Like do
  @moduledoc """
  """

  def like(earlier_name, except: kws) when is_list(kws),
    do: like(earlier_name, except: Enum.into(kws, %{}))

  def like(earlier_name, except: map) when is_map(map), 
    do: {:__like, earlier_name, map}

  def like(earlier_name), do: like(earlier_name, except: %{})


  def expand(new_pairs, :example_pairs, existing_pairs) do
    for {new_name, new_example} <- new_pairs do
      {new_name, expand(new_example, :example, existing_pairs)}
    end
  end

  def expand(example, :example, existing_pairs) do
    example
    |> expand_interior(:params, existing_pairs)
  end

  def expand_interior(example, _field, _existing_pairs) do
    example
  end

  

  def expand_likes(earlier_examples, candidate) do
    expand_likes_in(:params, earlier_examples, candidate)
  end


  


  def expand_likes_in(field, earlier_examples, candidate) do
    case Map.get(candidate, field) do
      {:__like, earlier_name, overrides} -> 
        model = Keyword.get(earlier_examples, earlier_name)
        model_values = Map.get(model, field)
        candidate_values = Map.merge(model_values, overrides)
        Map.put(candidate, field, candidate_values)
      _ ->
        candidate
    end
  end 
end
