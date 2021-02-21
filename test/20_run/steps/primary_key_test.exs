defmodule Run.Steps.PrimaryTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias Run.Steps
  import T.RunningStubs
  alias EctoTestDSL.Variants.PhoenixGranular.Update  

  test "default getter" do
    stub_history(params: %{"id" => "23"})
    stub(
      neighborhood: "--irrelevant--",
      repo: "--irrelevant--",
      get_primary_key_with: &Update.default_get_primary_key_with/3
    )
    
    actual = Steps.primary_key(:running)
    assert actual == "23"
  end
  

end
