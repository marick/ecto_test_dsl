defmodule Impl.SmartGet.ChangesetChecksTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl.SmartGet
  import TransformerTestSupport.Impl.Build

  describe "validity additions" do 
    test "a :validation_failure category has an `invalid` check put at the front" do
      test_data =
        start() |>
        category(:validation_failure,
          oops: [changeset(no_changes: [:date])]
        )
      
      SmartGet.changeset(test_data, :oops)
      |> assert_equal([:invalid, {:no_changes, [:date]}])
    end
    
    
    test "any other category gets a `valid` check" do
      test_data =
        start() |>
        category(:success,
          ok: [changeset(no_changes: [:date])]
        )
      
      SmartGet.changeset(test_data, :ok)
      |> assert_equal([:valid, {:no_changes, [:date]}])
    end
    
    test "checks are added even if there's no changest" do
      test_data =
        start() |>
        category(:success, ok: [])
      
      SmartGet.changeset(test_data, :ok)
      |> assert_equal([:valid])
    end
  end
end 
