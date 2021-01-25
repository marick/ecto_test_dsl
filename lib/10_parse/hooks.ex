defmodule EctoTestDSL.Parse.Hooks do
  use EctoTestDSL.Drink.Me


  # ----------------------------------------------------------------------------

  def run_hook(%{variant: variant} = test_data, hook_name, rest_args) do
    apply variant, :hook, [hook_name, test_data, rest_args]
  end

  # This allows tests not to create a `variant`. Does not apply to
  # non-test code.
  def run_hook(test_data, _hook_name, _rest_args), do: test_data

  def run_hook(test_data, hook_name) do
    run_hook(test_data, hook_name, [])
  end
end
  
