defmodule Run.Steps.SchemaAsCastTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias Run.Steps
  import T.RunningStubs
  use T.Parse.Exports


  defmodule Schema do
    use Ecto.Schema
    schema "bogus" do
      field :age, :integer
      field :date, :date
    end
  end
  
  setup do
    stub(name: :example, neighborhood: %{})
    stub(result_fields: %{}, result_matches: :unused)
    stub(as_cast: AsCast.new([:age, :date]))
    stub(schema: Schema)
    :ok
  end

  test "normal running in the absence of other checks" do
    stub_history(
      params: %{"age" => "1", "date" => "2012-03-03"},
      inserted_value: %{age: 1, date: ~D{2012-03-03}})

    actual = Steps.as_cast_field_checks(:running, :inserted_value)
    assert actual == :uninteresting_result
  end

  test "an as_cast failure" do 
    stub_history(
      params: %{"age" => "1", "date" => "2012-03-03"},
      inserted_value: %Schema{age: 2, date: ~D{2012-03-03}})

    assertion_fails(~r/Example `:example`: Field `:age` has the wrong value/,
      [message: ~r/according to `:as_cast/,
       message: ~r/Whole structure.*Schema.*age: 2/,
       left: 2, right: 1],
      fn -> 
        Steps.as_cast_field_checks(:running, :inserted_value)
      end)
  end

  test "as_cast is overridden by specific values" do
    stub(result_fields: %{age: 2})
    stub_history(
      params: %{"age" => "1", "date" => "2012-03-03"},
      inserted_value: %Schema{age: 2, date: ~D{2012-03-03}})

    actual = Steps.as_cast_field_checks(:running, :inserted_value)
    assert actual == :uninteresting_result
  end
  
end
