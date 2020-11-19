defmodule KeywordXTest do
  use ExUnit.Case

  test "translate" do
    expect = fn [kws, key_map], expected ->
      assert KeywordX.translate(kws, key_map) == expected
    end

    # Filters out values not mentioned in the second argument.
    [[a: 5], %{     }] |> expect.([    ])
    [[a: 5], %{a: :a}] |> expect.([a: 5])

    # Translations work
    [[a: 5], %{a: :b}] |> expect.([b: 5])

    # Just for fun
    [[a: 5, c: 3, d: 8], %{a: :b, c: :c}] |> expect.([b: 5, c: 3])
  end


  test "split_translate" do
    expect = fn [kws, key_map], expected ->
      assert KeywordX.split_and_translate(kws, key_map) == expected
    end
    
    [[a: 5], %{     }] |> expect.({[    ], [a: 5]})
    [[a: 5], %{a: :a}] |> expect.({[a: 5], [    ]})

    # Translations work
    [[a: 5], %{a: :b}] |> expect.({[b: 5], [    ]})

    # Just for fun
    [[a: 5, c: 3, d: 8], %{a: :b, c: :c}] |> expect.({[b: 5, c: 3], [d: 8]})
  end
end
