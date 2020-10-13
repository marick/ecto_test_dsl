defmodule Impl.Build.ParamsLikeTest do
  use TransformerTestSupport.Case
  use TransformerTestSupport.Impl.Predefines

  test "like" do
    start()
    |> category(:valid, ok: [                    params(a: 1, b: 2)])
    |> category(:invalid, similar: [params_like(:ok, except: [b: 4])])
    |> example(:similar)
    |> assert_field(params: %{a: 1, b: 4})
  end

  test "using like to refer to values within the same category" do
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
      start()
      |> category(:valid, [
          ok: [params: %{a: 1, b: 2}],
          similar: [params_like(:ok, except: [b: 4])]
        ])
      |> category(:invalid, [
           different: [params_like(:ok, except: [c: 383])]
        ])

    assert example(actual, :ok).params ==        %{a: 1, b: 2}
    assert example(actual, :similar).params ==   %{a: 1, b: 4}
    assert example(actual, :different).params == %{a: 1, b: 2, c: 383}
  end

  test "like can copy everything" do
    actual = 
      start()
      |> category(:valid, ok: [params(a: 1, b: 2)])
      |> category(:invalid, similar: [params_like(:ok)])

    assert example(actual, :ok).params == example(actual, :similar).params
  end
end  
