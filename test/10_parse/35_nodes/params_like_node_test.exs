defmodule EctoTestDSL.Parse.Node.ParamsLikeNodeTest do
  use EctoTestDSL.Case
  alias T.Parse.Node

  test "substitution" do
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
