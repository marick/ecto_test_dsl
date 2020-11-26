defmodule Build.ParamsShorthandTest do
  alias TransformerTestSupport, as: T
  use T.Case
  use T.Predefines
  alias T.Build

  defmodule Examples do 
    use Template.Trivial
  end

  describe "params_like" do 
    test "basic use" do
      Examples.started()
      |> workflow(:valid, ok: [                    params(a: 1, b: 2)])
      |> workflow(:invalid, similar: [params_like(:ok, except: [b: 4])])
      |> example(:similar)
      |> assert_field(params: %{a: 1, b: 4})
    end
    
    test "using params_like to refer to values within the same workflow" do
      Examples.started()
      |> workflow(:valid, [
            ok: [params: %{a: 1, b: 2}],
            similar: [params_like(:ok, except: [b: 4])]
      ])
      |> example(:similar)
      |> assert_field(params: %{a: 1, b: 4})
    end
    
    test "multiple workflows" do
      actual = 
        Examples.started() |> 

        workflow(:valid, [
              ok: [params: %{a: 1, b: 2}],
              similar: [params_like(:ok, except: [b: 4])]
           ]) |> 

        workflow(:invalid, [
              different: [params_like(:ok, except: [c: 383])]
        ])
          
      assert example(actual, :ok).params ==        %{a: 1, b: 2}
      assert example(actual, :similar).params ==   %{a: 1, b: 4}
      assert example(actual, :different).params == %{a: 1, b: 2, c: 383}
    end
    
    test "params_like can copy everything" do
      actual = 
        Examples.started()
        |> workflow(:valid, ok: [params(a: 1, b: 2)])
        |> workflow(:invalid, similar: [params_like(:ok)])
      
      assert example(actual, :ok).params == example(actual, :similar).params
    end

    test "referring to a nonexistent example fails gracefully" do
      assertion_fails("There is no previous example `:ok`",
        fn ->
          Examples.started()
          |> workflow(:invalid, similar: [params_like(:ok)])
        end)
    end
  end
    
  describe "id_of" do 
    test "instances of `id_of` generate a previously" do
      actual = 
        Examples.started()
        |> workflow(:valid, ok: [params(a: 1, b: 2)])
        |> workflow(:invalid, similar: [
              params_like(:ok, except: [a: id_of(species: ExampleModule)])
           ])

      assert example(actual, :similar).previously == [insert: {:species, ExampleModule}]
    end

    test "adds on to existing previously" do
      actual = 
        Examples.started()
        |> workflow(:invalid, name: [
             params(a: id_of(species: ExampleModule),
                    b: id_of(:thing)),
             previously(insert: :noog)
        ])

      assert example(actual, :name).previously ==
          [insert: :noog,
           insert: {:species, ExampleModule},
           insert: {:thing, __MODULE__}]
    end
  end
end  
