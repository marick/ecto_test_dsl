defmodule Impl.SmartGet.ChangesetAsCastTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl.SmartGet.ChangesetAsCast, as: UnderTest
  alias TransformerTestSupport.Impl.SmartGet
  use Ecto.Schema
  import Ecto.Changeset
  import TransformerTestSupport.Impl.Build

  embedded_schema do
    field :name, :string
    field :date, :date
    field :other, :string
    field :other2, :string
  end

  describe "mechanisms" do
    test "collecting valid changes" do
      params = %{"name" => "Bossie", "date" => "2001-01-01"}
      changeset = cast(struct(__MODULE__), params, [:name, :date])
      
      UnderTest.to_changeset_notation(changeset, [:name, :date])
      |> assert_field(changes: [name: "Bossie", date: ~D[2001-01-01]])
    end

    test "a cast that fails" do
      params = %{"name" => "Bossie", "date" => "2001-01-0"}
      #                                                 ^^
      changeset = cast(struct(__MODULE__), params, [:name, :date])
      
      UnderTest.to_changeset_notation(changeset, [:name, :date])
      |> assert_fields(changes: [name: "Bossie"],
                       no_changes: [:date],
                       errors: [date: "is invalid"])
    end
  end



  describe "adding an automatic as_cast test" do
    test "starting with nothing" do 
      test_data =
        start(module_under_test: __MODULE__)
        |> field_transformations(as_cast: [:date])
        |> category(:success, ok: [params(date: "2001-01-01")])

      SmartGet.changeset(test_data, :ok)
      |> assert_equal([:valid, changes: [date: ~D[2001-01-01]]])
      
    end
  end
  
end 
