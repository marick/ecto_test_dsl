defmodule Parse.ParamsTest do
  use TransformerTestSupport.Case
  use T.Predefines
  alias T.Build

  defmodule Examples do
    use Template.Trivial

    def create_test_data do
      started() |>

      workflow(:success,
        first: [params(a: 1, b: 2)],
        next: [params_like(:first, except: [b: 22, c: 3])]
      )
    end
  end

  test "params and params like (including expansion phase)" do
    assert Examples.Tester.example(:first).params == %{a: 1, b: 2}
    assert Examples.Tester.example(:next).params == %{a: 1, b: 22, c: 3}
  end
end
