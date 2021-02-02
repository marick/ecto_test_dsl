defmodule Parse.PreviouslyTest do
  use EctoTestDSL.Case
  use T.Parse.All

  def expect(input, expected) do
    %{module_under_test: Schema, examples_module: Examples, examples: []}
    |> workflow(:success, example: [input])
    |> Map.get(:examples)
    |> Keyword.get(:example)
    |> Map.get(:previously)
    |> assert_equal(expected)
  end

  @tag :skip
  test "expansion of `previously` arguments" do
    previously(insert: :a)         |> expect([insert: een(a: Examples)])
    previously(insert: [:a, :b]) |> expect([insert: een(a: Examples),
                                            insert: een(b: Examples)])
    previously(insert: :a, insert: [:b, :c]) |> expect([insert: een(a: Examples),
                                                       insert: een(b: Examples),
                                                        insert: een(c: Examples)])

    previously(insert: [a: Other]) |> expect([insert: een(:a, Other)])
    previously(insert: [a: Examples, b: Other]) |> expect([insert: een(:a, Examples),
                                                          insert: een(:b, Other)])
    
    previously(insert: [:a, :b, c: Other]) |> expect([insert: een(:a, Examples),
                                                      insert: een(:b, Examples),
                                                      insert: een(:c, Other)])
  end
end
