defmodule Run.Steps.PrimaryTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias Run.Steps
  import T.RunningStubs
  alias EctoTestDSL.Variants.PhoenixGranular.Update  

  describe "default getter" do
    setup do 
      stub(
        neighborhood: "--irrelevant--",
        get_primary_key_with: &Update.default_get_primary_key_with/1
      )
      :ok
    end
      
    test "success" do
      stub_history(params: %{"id" => "23"})
    
      assert Steps.primary_key(:running) == "23"
    end

    test "missing key in params" do
      stub_history(params: %{"pid" => "23"})

      assertion_fails(
        ~r/You probably need to set `:get_primary_key_with` in your `start` function/,
        fn ->
          Steps.primary_key(:running)
        end)
    end
  end


  describe "overridding the primary key getter" do
    setup do 
      stub(neighborhood: "--irrelevant--")
      stub_history(params: "--irrelevant--")
      :ok
    end
      
    test "the neighborhood is made available" do
      stub(neighborhood: "a primary key source")
      stub(get_primary_key_with: fn %{neighborhood: neighborhood} ->
        neighborhood
      end)
    
      assert Steps.primary_key(:running) == "a primary key source"
    end
  end
end
