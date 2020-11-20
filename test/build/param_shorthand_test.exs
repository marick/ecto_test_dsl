defmodule Build.ParamsShorthandTest do
  alias TransformerTestSupport, as: T
  use T.Case
  use T.Predefines
  alias T.Build

  describe "params_like" do 
    test "basic use" do
      start()
      |> category(:valid, ok: [                    params(a: 1, b: 2)])
      |> category(:invalid, similar: [params_like(:ok, except: [b: 4])])
      |> example(:similar)
      |> assert_field(params: %{a: 1, b: 4})
    end
    
    test "using params_like to refer to values within the same category" do
      start()
      |> category(:valid, [
            ok: [params: %{a: 1, b: 2}],
            similar: [params_like(:ok, except: [b: 4])]
      ])
      |> example(:similar)
      |> assert_field(params: %{a: 1, b: 4})
    end
    
    test "multiple categories" do
      actual = 
        start() |> 

        category(:valid, [
              ok: [params: %{a: 1, b: 2}],
              similar: [params_like(:ok, except: [b: 4])]
           ]) |> 

        category(:invalid, [
              different: [params_like(:ok, except: [c: 383])]
        ])
          
      assert example(actual, :ok).params ==        %{a: 1, b: 2}
      assert example(actual, :similar).params ==   %{a: 1, b: 4}
      assert example(actual, :different).params == %{a: 1, b: 2, c: 383}
    end
    
    test "params_like can copy everything" do
      actual = 
        start()
        |> category(:valid, ok: [params(a: 1, b: 2)])
        |> category(:invalid, similar: [params_like(:ok)])
      
      assert example(actual, :ok).params == example(actual, :similar).params
    end

    test "referring to a nonexistent example fails gracefully" do
      assertion_fails("There is no previous example `:ok`",
        fn ->
          Build.start(module_under_test: ModuleUnderTest)
          |> category(:invalid, similar: [params_like(:ok)])
        end)
    end
  end
    
  describe "id_of" do 
    test "instances of `id_of` generate a setup" do
      actual = 
      start()
      |> category(:valid, ok: [params(a: 1, b: 2)])
      |> category(:invalid, similar: [
            params_like(:ok, except: [a: id_of(species: ExampleModule)])
         ])

      assert example(actual, :similar).setup == [insert: {:species, ExampleModule}]
    end

    test "adds on to existing setup" do
      actual = 
        start()
        |> category(:invalid, name: [
             params(a: id_of(species: ExampleModule),
                    b: id_of(:thing)),
             Build.setup(insert: :noog)
        ])

      assert example(actual, :name).setup ==
          [insert: :noog,
           insert: {:species, ExampleModule},
           insert: {:thing, __MODULE__}]
    end
  end
end  
