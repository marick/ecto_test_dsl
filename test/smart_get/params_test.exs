defmodule Setup.ParamsTest do
  use TransformerTestSupport.Case
  use T.Parse.All
  alias T.Setup
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
      |> Setup.Params.get(previously: %{})
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
    |> Setup.Params.get(previously: previously)
    |> assert_fields(name: "bossie", species_id: 112)
  end


  describe "resolve_field_refs" do 
    alias T.Setup.Params      

    @example_has_5 %{een(:example) => %{id: 5}}

    test "fieldref success cases" do
      expect = fn [list, examples], expected ->
        assert Params.resolve_field_refs(list, examples) == expected
      end
      
      [ [    ], %{                      } ] |> expect.([    ])
      [ [a: 5], %{                      } ] |> expect.([a: 5])
      [ [a: 5], %{een(:example) => "..."} ] |> expect.([a: 5])
      
      [ [a: id_of(:example)], @example_has_5] |> expect.([a: 5])
      
      [ [:z, {:a, id_of(:example)}], @example_has_5] |> expect.([:z, {:a, 5}])
    end
    
    test "any_cross_reference_values failure" do
      assertion_fails("There is no example named `:examp` in ParamsTest",
        fn ->
          Params.resolve_field_refs([a: id_of(:examp)], @example_has_5)
        end)
    end 
  end 
end
