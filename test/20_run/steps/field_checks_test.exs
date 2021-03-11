defmodule Run.Steps.FieldChecksTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias Run.Steps
  use Mockery
  import T.RunningStubs
  import T.Parse.InternalFunctions

  setup do
    stub(name: :example, neighborhood: %{}, usually_ignore: [])
    stub(fields_from: :nothing)  # fields_from is checked in fields_from_test.exs
    :ok
  end

  defp run([checks, value]) do 
    stub_history(inserted_value: value)
    stub(field_checks: checks)
    Steps.field_checks(:running, :inserted_value)
  end

  defp pass(setup), do: assert run(setup) == :uninteresting_result

  test "expected values" do
    [ %{name: "Bossie"}, %{name: "Bossie"}] |> pass()
  end
    
  test "expected change has wrong value" do
    input = [ %{name: "Bossie"}, %{name: ""}]
    
    assertion_fails(~r/Example `:example`/,
      [message: ~r/Field `:name` has the wrong value/,
       left: "",
       right: "Bossie"],
      fn ->
        run(input)
      end)
  end

  test "extra values are OK" do
    [ %{name: "Bossie"}, %{name: "Bossie", age: 5}] |> pass
  end

  test "references to neighbors are supported" do
    other_een = een(:other_example)
    stub(neighborhood: %{other_een => Neighborhood.Value.inserted(%{id: 333})})

    passes = [ %{other_id: id_of(:other_example)}, %{other_id: 333}]
    fails =  [ %{other_id: id_of(:other_example)}, %{other_id: "NOT"}]

    passes |> pass()

    assertion_fails(~r/Example `:example`/,
      [message: ~r/Field `:other_id` has the wrong value/,
       left: "NOT",
       right: 333],
      fn ->
        run(fails)
      end)
  end
end
