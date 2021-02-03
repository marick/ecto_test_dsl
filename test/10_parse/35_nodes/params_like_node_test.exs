defmodule EctoTestDSL.Parse.Node.ParamsLikeNodeTest do
  use EctoTestDSL.Case
  use T.Predefines
  alias T.Parse.Node

  defmodule Examples do 
    use Template.Trivial
  end

  describe "params_like" do 
    test "basic use" do
      test_data = 
        Examples.started()
        |> workflow(:valid, ok: [                    params(a: 1, b: 2)])
        |> workflow(:invalid, similar: [params_like(:ok, except: [b: 4])])

      test_data
      |> example(:similar)
      |> assert_field(params: %{a: 1, b: 4})
    end
    
    test "using params_like to refer to values within the same workflow" do
      test_data = 
        Examples.started()
        |> workflow(:valid, [
            ok: [params: %{a: 1, b: 2}],
            similar: [params_like(:ok, except: [b: 4])]
           ])

      test_data
      |> example(:similar)
      |> assert_field(params: %{a: 1, b: 4})
    end
    
    test "multiple workflows" do
      test_data = 
        Examples.started() |> 

        workflow(:valid, [
              ok: [params: %{a: 1, b: 2}],
              similar: [params_like(:ok, except: [b: 4])]
           ]) |> 

        workflow(:invalid, [
              different: [params_like(:ok, except: [c: 383])]
        ])
          
      assert example(test_data, :ok).params ==        %{a: 1, b: 2}
      assert example(test_data, :similar).params ==   %{a: 1, b: 4}
      assert example(test_data, :different).params == %{a: 1, b: 2, c: 383}
    end
    
    test "params_like can copy everything" do
      test_data = 
        Examples.started()
        |> workflow(:valid, ok: [params(a: 1, b: 2)])
        |> workflow(:invalid, similar: [params_like(:ok)])
      
      assert example(test_data, :ok).params == example(test_data, :similar).params
    end

    test "referring to a nonexistent example fails gracefully" do
      assertion_fails("There is no previous example `:ok`",
        fn ->
          Examples.started()
          |> workflow(:invalid, similar: [params_like(:ok)])
        end)
    end
  end

  test "no exceptions" do
    previous_examples = [previous: %{params: %{a: 1, b: 2}}]

    run = fn [name, exceptions] -> 
      Node.ParamsLike.new(name, exceptions)
      |> Node.ParseTimeSubstitutable.substitute(previous_examples)
    end

    expect = fn input, expected ->
      assert run.(input) == expected
    end

    [:previous, []] |> expect.(%{a: 1, b: 2})
    [:previous, [a: "a"] ] |> expect.(%{a: "a", b: 2})

    # Adding a new field is a little dubious but maybe worth it?
    [:previous, [c: "c"] ] |> expect.(%{a: 1, b: 2, c: "c"})

    assertion_fails("There is no previous example `:missing`",
      fn ->
        [:missing, [c: "c"] ] |> run.()
      end)
  end
end  
