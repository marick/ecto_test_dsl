defmodule TransformerTestSupport.Neighborhood.Expand do
  use TransformerTestSupport.Drink.Me

  def params(params, with: neighborhood) do
    for {param_name, param_value} <- params do
      case param_value do
        %FieldRef{} = ref ->
          {param_name, FieldRef.dereference(ref, in: neighborhood)}
        _ ->
          {param_name, param_value}
      end
    end
    |> Map.new
  end
end
