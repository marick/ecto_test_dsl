defmodule Formats.PhoenixFormatTest do
  use EctoTestDSL.Case
  alias Formats.Phoenix

  @params %{
    age: 1,
    date_string: "2011-02-03",
    nested: %{a: 3},
    list: [1, 2, 3],
    date: ~D[2001-02-03],
    dates: [~D[2001-02-03]],
    complex: %{a: [~D[2001-02-03], %{a: [~D[2002-02-02]]}]}
  }
  
  @interpreted_as_phoenix %{
    "age" => "1",
    "date_string" => "2011-02-03",
    "nested" => %{"a" => "3"},
    "list" => ["1", "2", "3"],
    "date" => "2001-02-03",
    "dates" => ["2001-02-03"],
    "complex" => %{"a" => ["2001-02-03", %{"a" => ["2002-02-02"]}]}
  }
  
  test "different formats" do
    assert Phoenix.format(@params) == @interpreted_as_phoenix
  end

  defmodule Struct do
    defstruct dates: [~D[2001-02-03]]
  end

  test "any __meta__ tag is removed" do
    assert Phoenix.format(%Struct{}) == %{"dates" => ["2001-02-03"]}
  end

  test "allows an unstringifiable value through" do
    assert Phoenix.format(%{a: {:ok, 5}}) == %{"a" => {:ok, 5}}
  end
end
