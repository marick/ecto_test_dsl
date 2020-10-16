defmodule Impl.SmartGet.ChangesetAsCastTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl.SmartGet.ChangesetAsCast, as: UnderTest
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
    test "extract cast fields" do
      %{field_transformations: [name: :as_cast, date: :as_cast, other: :other]}
      |> UnderTest.as_cast_fields
      |> assert_equal([:name, :date])
    end

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
end 
