defmodule Run.Steps.ParamsSelectedTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  import T.RunningStubs
  alias Run.Steps
#  import T.Parse.InternalFunctions

  setup do
    stub(name: :example)
    :ok
  end

  defp run([{other, values}]) do
    stub(
      params_from_selecting: een(other),
      neighborhood: %{een(other) => values})
    Steps.params_from_selecting(:running)
  end

  defp expect(setup, expected) do
    actual = run(setup)
    assert actual == expected
  end

  test "expected values" do
    [other: %{field1: "1", field2: "2"}] |> expect(%{field1: "1", field2: "2"})
  end
end
