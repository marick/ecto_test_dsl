defmodule Impl.SmartGet.ChangesetChecksTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl.SmartGet
  import TransformerTestSupport.Impl.Build

  # ----------------------------------------------------------------------------
  describe "validity additions" do 
    test "a :validation_failure category has an `invalid` check put at the front" do
      test_data =
        start() |>
        category(:validation_failure,
          oops: [changeset(no_changes: [:date])]
        ) |> propagate_metadata
      
      SmartGet.ChangesetChecks.get(test_data, :oops)
      |> assert_equal([:invalid, {:no_changes, [:date]}])
    end
    
    
    test "any other category gets a `valid` check" do
      test_data =
        start() |>
        category(:success,
          ok: [changeset(no_changes: [:date])]
        ) |> propagate_metadata
      
      
      SmartGet.ChangesetChecks.get(test_data, :ok)
      |> assert_equal([:valid, {:no_changes, [:date]}])
    end
    
    test "checks are added even if there's no changest" do
      test_data =
        start() |>
        category(:success, ok: [])
        |> propagate_metadata
      
      SmartGet.ChangesetChecks.get(test_data, :ok)
      |> assert_equal([:valid])
    end
  end

  # ----------------------------------------------------------------------------
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :name, :string
    field :date, :date
    field :other, :string
    field :other2, :string
  end


  describe "adding an automatic as_cast test" do
    test "starting with nothing" do 
      test_data =
        start(module_under_test: __MODULE__)
        |> field_transformations(as_cast: [:date])
        |> category(:success, ok: [params(date: "2001-01-01")])
        |> propagate_metadata

      SmartGet.ChangesetChecks.get(test_data, :ok)
      |> assert_equal([:valid, changes: [date: ~D[2001-01-01]]])
      
    end
  end
  

  
  

  describe "mechanisms" do
    test "collecting valid changes" do
      params = %{"name" => "Bossie", "date" => "2001-01-01"}
      changeset = cast(struct(__MODULE__), params, [:name, :date])
      
      SmartGet.ChangesetChecks.to_changeset_notation(changeset, [:name, :date])
      |> assert_field(changes: [name: "Bossie", date: ~D[2001-01-01]])
    end

    test "a cast that fails" do
      params = %{"name" => "Bossie", "date" => "2001-01-0"}
      #                                                 ^^
      changeset = cast(struct(__MODULE__), params, [:name, :date])
      
      SmartGet.ChangesetChecks.to_changeset_notation(changeset, [:name, :date])
      |> assert_fields(changes: [name: "Bossie"],
                       no_changes: [:date],
                       errors: [date: "is invalid"])
    end
  end



end 
