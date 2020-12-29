defmodule TransformerTestSupport.Parse.Hooks do
  use TransformerTestSupport.Drink.Me


  # ----------------------------------------------------------------------------

  def has_hook?(nil, _hook_tuple), do: false
  
  def has_hook?(variant, hook_tuple), 
    do: hook_tuple in variant.__info__(:functions)

  def run_variant(test_data, hook_name, rest_args) do
    hook_tuple = {hook_name, 1 + length(rest_args)}
    variant = Map.get(test_data, :variant)  
    case has_hook?(variant, hook_tuple) do
      true ->
        apply variant, hook_name, [test_data | rest_args]
      false ->
        test_data
    end
  end

  def run_start_hook(%{variant: variant} = test_data_so_far),
    do: apply variant, :run_start_hook, [test_data_so_far]
end
  
