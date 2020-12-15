defmodule SmartGet.ParamsTest do
  use TransformerTestSupport.Drink.Me
  use T.Case
  import T.Build
  alias Template.Dynamic

  defmodule Examples do
    use Template.Trivial
  end
  

  @params params(
    age: 1,
    date: "2011-02-03",
    nested: %{a: 3},
    list: [1, 2, 3])

  @interpreted_as_phoenix %{
    "age" => "1",
    "date" => "2011-02-03",
    "nested" => %{"a" => "3"},
    "list" => ["1", "2", "3"]}

  @interpreted_as_raw Keyword.get([@params], :params) |> Enum.into(%{})

  test "different formats" do
    expect = fn format, expected ->
      Dynamic.configure(Examples)
      |> Dynamic.adjust_metadata(format)
      |> Dynamic.example([@params])
      |> SmartGet.Params.get(previously: %{})
      |> assert_fields(expected)
    end

    [format: :phoenix] |> expect.(@interpreted_as_phoenix)
    [format: :raw    ] |> expect.(@interpreted_as_raw)
    [                ] |> expect.(@interpreted_as_raw)
  end


  defmodule ExamplesIdOf do
    use Template.Trivial

    def create_test_data() do
      started() |> 
      workflow(:any_workflow,
        species: [params(name: "bovine")],
        animal:  [params(name: "bossie", species_id: id_of(:species))]
      )
    end
  end
    
  test "getting the id of a previously-created value" do
    previously =
      %{een(species: ExamplesIdOf) => %{id: 112, name: "bovine"}}
    
    ExamplesIdOf.Tester.example(:animal)
    |> SmartGet.Params.get(previously: previously)
    |> assert_fields(name: "bossie", species_id: 112)
  end

end 
