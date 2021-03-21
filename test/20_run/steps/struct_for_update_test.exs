defmodule Run.Steps.StructForUpdateTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias Run.Steps
  import T.RunningStubs

  setup do 
    stub_history(primary_key: 333)
    stub(repo: "repo", api_module: "module")
    :ok
  end
      
  test "success" do
    stub(struct_for_update_with: fn ~M{repo, api_module, primary_key} ->
      assert repo == "repo"
      assert api_module == "module"
      assert primary_key == 333
      
      "some result"
    end)

    assert Steps.struct_for_update(:running, :primary_key) == "some result"
  end
end
