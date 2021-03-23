defmodule Nouns.AsCastTest do
  use EctoTestDSL.Case
  alias T.Nouns.AsCast

  defmodule Association do
    use Ecto.Schema

    schema "association" do 
      field :value, :integer
    end
  end

  defmodule Schema do
    use Ecto.Schema

    schema "struct" do 
      field :int_field, :integer, virtual: true
      field :string_field, :string
      field :date_string, :string, virtual: true
      belongs_to :association_field, Association
    end
  end


  test "merging" do
    AsCast.nothing
    |> AsCast.merge(AsCast.new([:a]))
    |> assert_fields(field_names: [:a])
    |> AsCast.merge(AsCast.new([:b]))
    |> assert_fields(field_names: [:a, :b])
  end

  test "subtracting field names" do
    AsCast.new([:a, :b, :c])
    |> AsCast.subtract([:b, :c, :d])
    |> assert_fields(field_names: [:a])
  end
end 
