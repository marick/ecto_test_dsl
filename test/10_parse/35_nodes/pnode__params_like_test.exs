defmodule EctoTestDSL.Parse.Pnode.ParamsLikeTest do
  use EctoTestDSL.Case
  alias T.Parse.Pnode

  test "substitution" do
    previous_examples = [previous: %{params: Pnode.Params.parse(%{a: 1, b: 2})}]

    run = fn [name, exceptions] -> 
      Pnode.ParamsLike.new(name, exceptions)
      |> Pnode.Substitutable.substitute(previous_examples)
    end

    expect = fn input, expected ->
      assert run.(input) == Pnode.Params.parse(expected)
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
