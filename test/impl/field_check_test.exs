defmodule TransformerTestSupport.Impl.FieldCheckTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl.Build


  def assert_raises_runtime_error(snippets, f) do
    checks = for s <- snippets, do: {:message, s}
    
    assert_raise(RuntimeError, f)
    |> assert_fields(checks)
  end

  test "required top-level fields are present" do
    assert_raises_runtime_error([~r/The following fields are required/,
                                 ~r/:module_under_test/],
      fn -> Build.create_test_data([]) end)
  end

  test "rejects unknown fields" do
    assert_raises_runtime_error([~r/The following fields are unknown/,
                                 ~r/:examplars/,
                                 ~r/:exemplars/],
      fn -> Build.create_test_data([module_under_test: List,
                         examplars: []
                        ]) end)
  end
end
