defmodule SmartGet.ParamsTest do
  alias TransformerTestSupport, as: T
  use T.Case
  alias T.SmartGet
  import T.Build

  @ok [params: [age: 1,
                date: "2011-02-03",
                nested: %{a: 3},
                list: [1, 2, 3]]]

  @phoenix_params %{
    "age" => "1",
    "date" => "2011-02-03",
    "nested" => %{"a" => "3"},
    "list" => ["1", "2", "3"]}

  @raw_params Keyword.get(@ok, :params) |> Enum.into(%{})

  def with_format(start_args),
    do: TestBuild.one_category(start_args, [ok: @ok])

  test "different formats" do
    expect = fn format, expected ->
      with_format(format)
      |> SmartGet.Example.get(:ok)
      |> SmartGet.Params.get(previously: %{})
      |> assert_fields(expected)
    end

    [format: :phoenix] |> expect.(@phoenix_params)
    [format: :raw    ] |> expect.(@raw_params)
    [                ] |> expect.(@raw_params)
  end
    
  test "getting the id of a previously-created value" do
    TestBuild.one_category(
      species: [params(name: "bovine")],
      animal:  [params(name: "bossie", species_id: id_of(:species))]
    )
    |> SmartGet.Example.get(:animal)
    |> SmartGet.Params.get(previously: %{{:species, __MODULE__} => %{id: 112, name: "bovine"}})
    |> assert_fields(name: "bossie", species_id: 112)
  end

end 
