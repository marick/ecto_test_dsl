defmodule KeywordXTest do
  use TransformerTestSupport.Drink.Me
  use ExUnit.Case

  test "translate_keys" do
    expect = fn [kws, key_map], expected ->
      assert KeywordX.translate_keys(kws, key_map) == expected
    end

    # Filters out values not mentioned in the second argument.
    [[a: 5], %{     }] |> expect.([    ])
    [[a: 5], %{a: :a}] |> expect.([a: 5])

    # Translations work
    [[a: 5], %{a: :b}] |> expect.([b: 5])

    # Just for fun
    [[a: 5, c: 3, d: 8], %{a: :b, c: :c}] |> expect.([b: 5, c: 3])
  end


  test "split_and_translate_keys" do
    expect = fn [kws, key_map], expected ->
      assert KeywordX.split_and_translate_keys(kws, key_map) == expected
    end
    
    [[a: 5], %{     }] |> expect.({[    ], [a: 5]})
    [[a: 5], %{a: :a}] |> expect.({[a: 5], [    ]})

    # Translations work
    [[a: 5], %{a: :b}] |> expect.({[b: 5], [    ]})

    # Just for fun
    [[a: 5, c: 3, d: 8], %{a: :b, c: :c}] |> expect.({[b: 5, c: 3], [d: 8]})
  end

  test "`filter/reject_by_value` preserves structure, deletes unwanted values" do
    assert KeywordX.filter_by_value([a: 1, b: "b"], &is_integer/1) == [a: 1]
    assert KeywordX.reject_by_value([a: 1, b: "b"], &is_integer/1) == [b: "b"]
  end

  test "`filter_by_key` preserves structure, deletes unwanted keys" do
    assert KeywordX.filter_by_key([a: 1, b: "b"], &(&1 == :a)) == [a: 1]
    assert KeywordX.reject_by_key([a: 1, b: "b"], &(&1 == :a)) == [b: "b"]
  end

  test "delete" do
    assert KeywordX.delete([a: 1, b: 2],  :a     ) == [b: 2]
    assert KeywordX.delete([a: 1, b: 2], [:a    ]) == [b: 2]
    assert KeywordX.delete([a: 1, b: 2], [:a, :b]) == [    ]
  end

  test "`map_values` loses keys, transforms values" do
    assert KeywordX.map_values([a: 1, b: 2], &(-&1)) == [-1, -2]
  end

  test "`map_over_values` retains keys, transforms values" do
    assert KeywordX.map_over_values([a: 1, b: 2], &(-&1)) == [a: -1, b: -2]
  end


  test "split_by_value_predicate" do
    lt0 = &(&1 < 0)

    input = [a: 1, b: 2, c: -1, d: 1]
    actual = KeywordX.split_by_value_predicate(input, lt0)
    expected = %{true: [c: -1],
                 false: [a: 1, b: 2, d: 1] }
    assert actual == expected

    # missing values
    actual = KeywordX.split_by_value_predicate([], lt0)
    expected = %{true: [], false: []}
    assert actual == expected
    
    
  end
  
  defmodule Struct do
    defstruct [:val]
    
    def transform(s), do: String.upcase(s.val)
  end
  
  defmodule Other do 
    defstruct [:val]
    
    def transform(s), do: s.val + 100
  end

  test "`update_matching_structs`" do
    args = [s: %Struct{val: "down"}, fnord: 3, o: %Other{val: 5}]
    transforms = [Struct, &Struct.transform/1, Other, &Other.transform/1]
    actual = KeywordX.update_matching_structs(args, transforms) 
    assert actual == [s: "DOWN", fnord: 3, o: 105]
  end

  test "shorthand for single transform" do 
    args = [s: %Struct{val: "down"}, fnord: 3]
    actual = KeywordX.update_matching_structs(args, Struct, &Struct.transform/1)
    assert actual == [s: "DOWN", fnord: 3]
  end

  test "this is tolerant of list values that are not key-value pairs" do
    args = [:key, fnord: 3]
    transforms = [Struct, &Struct.transform/1]
    actual = KeywordX.update_matching_structs(args, transforms) 
    assert actual == [:key, fnord: 3]
  end
end
