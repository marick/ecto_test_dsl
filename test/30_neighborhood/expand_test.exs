defmodule Neighborhood.ExpandTest do
  use EctoTestDSL.Case
  alias T.Neighborhood.Expand
  use T.Parse.Exports

  test "keyword values" do
    expect = TabularA.run_and_assert(fn [original, neighborhood] ->
      Expand.values(original, with: neighborhood)
    end)

    unchanged = fn [original, neighborhood] ->
      [original, neighborhood] |> expect.(original)
    end

    neighborhood = %{een(:neighbor) => Neighborhood.Value.inserted(%{id: 5})}

    [%{a: 1}, %{}] |> unchanged.()
    [%{a: id_of(:neighbor)}, neighborhood] |> expect.(%{a: 5})

    # Nesting
    [%{notes: %{text: "t"}}, %{}] |> unchanged.()

    [%{         notes: %{id: id_of(:neighbor)}}, neighborhood] |>
      expect.(%{notes: %{id: 5}})


    # A nested list
    [%{         notes:  [%{id: id_of(:neighbor)},
                         %{id: id_of(:neighbor), extra: "e"}]}, neighborhood] |> 

      expect.(%{notes: [%{id: 5},
                        %{id: 5, extra: "e"}]})

    # A list of values
    [%{          notes: [1, id_of(:neighbor), 3]}, neighborhood]
    |> expect.(%{notes: [1, 5,                3]})
  end

  # ----------------------------------------------------------------------------

  test "changeset_checks" do
    checks =   [:valid, changes: [a: 3, b: id_of(:other)]]
    expected = [:valid, changes: [a: 3, b: 3838]]
    actual = Expand.changeset_checks(checks, %{een(:other) => %{id: 3838}})
    assert actual == expected
  end

  test "tested_replace_check_values" do
    expect = TabularA.run_and_assert(fn original ->
      predicate = &is_binary/1
      replacer = &String.upcase/1
      Expand.tested_replace_check_values(original, predicate, replacer)
    end)

    unchanged = fn original -> original |> expect.(original) end

    unchanged.([:valid])
    unchanged.([:valid,
                changes: [a: 3, b: 4],
                changes: [:a, :b],
                change: :a,
                error_free: [:a, :b]])

    [changes: [a: 3, b: "four"]] |> expect.([changes: [a: 3, b: "FOUR"]])
  end
end
