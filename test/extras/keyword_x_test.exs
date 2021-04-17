defmodule KeywordXTest do
  use EctoTestDSL.Case

  test "translate_keys" do
    expect = TabularA.run_and_assert(&KeywordX.translate_keys/2)

    # Filters out values not mentioned in the second argument.
    [[a: 5], %{     }] |> expect.([    ])
    [[a: 5], %{a: :a}] |> expect.([a: 5])

    # Translations work
    [[a: 5], %{a: :b}] |> expect.([b: 5])

    # Just for fun
    [[a: 5, c: 3, d: 8], %{a: :b, c: :c}] |> expect.([b: 5, c: 3])
  end


  test "split_and_translate_keys" do
    expect = TabularA.run_and_assert(&KeywordX.split_and_translate_keys/2)
    
    [[a: 5], %{     }] |> expect.({[    ], [a: 5]})
    [[a: 5], %{a: :a}] |> expect.({[a: 5], [    ]})

    # Translations work
    [[a: 5], %{a: :b}] |> expect.({[b: 5], [    ]})

    # Just for fun
    [[a: 5, c: 3, d: 8], %{a: :b, c: :c}] |> expect.({[b: 5, c: 3], [d: 8]})
  end

  test "delete" do
    assert KeywordX.delete([a: 1, b: 2],  :a     ) == [b: 2]
    assert KeywordX.delete([a: 1, b: 2], [:a    ]) == [b: 2]
    assert KeywordX.delete([a: 1, b: 2], [:a, :b]) == [    ]
  end

  test "`functor_map` retains keys, transforms values" do
    assert KeywordX.functor_map([a: 1, b: 2], &(-&1)) == [a: -1, b: -2]
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

  test "assert_no_duplicate_keys" do
    a = assertion_runners_for(&KeywordX.assert_no_duplicate_keys/1)

    [               ] |> a.pass.()
    [a: 1, b: 2     ] |> a.pass.()

    [a: 1, b: 2, a: 3] |> a.fail.("Keyword list should not have duplicate keys")
                       |> a.plus.(left: [a: 1, b: 2, a: 3],
                                  right: [:a, :b, :a])
  end


  test "at_most_this_key?" do
    assert KeywordX.at_most_this_key?([], :key)
    assert KeywordX.at_most_this_key?([key: 1], :key)
    refute KeywordX.at_most_this_key?([key: 1, other: 2], :key)
    refute KeywordX.at_most_this_key?([not: 1], :key)
  end

  test "if list is a keyword list" do
    expect = TabularA.run_and_assert(&KeywordX.is_keyword_list/1)

    [] |> expect.(false)
    [1] |> expect.(false)
    [a: 3] |> expect.(true)

    # Only checks the first value
    [{:a, 3}, 3] |> expect.(true)
  end
      
end
