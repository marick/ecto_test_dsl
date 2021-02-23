defmodule Run.Steps.StructForUpdateTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias Run.Steps
  import T.RunningStubs

  setup do 
    stub_history(primary_key: 333)
    stub(repo: "repo", module_under_test: "module")
    :ok
  end
      
  test "success" do
    stub(struct_for_update_with: fn ~M{repo, module_under_test, primary_key} ->
      assert repo == "repo"
      assert module_under_test == "module"
      assert primary_key == 333
      
      "some result"
    end)

    assert Steps.struct_for_update(:running, :primary_key) == "some result"
  end
end
