defmodule Run.Steps.CheckIdInsertionTest do
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
    stub(name: :example, schema: Schema, repo: "unused")
    :ok
  end

  test "ID must be present" do
    stub_history(
      existing_ids: [1, 2, 3],
      inserted_value: %{id: 4})
    stub(existing_ids_with: fn _ -> [1, 2, 3, 4] end)

    assert Steps.assert_id_inserted(:running, :inserted_value) == :uninteresting_result
  end

  test "failure to insert" do
    stub_history(
      existing_ids: [1, 2, 3],
      inserted_value: %{id: 4})
    stub(existing_ids_with: fn _ -> [1, 2, 3] end)

    assertion_fails(~r/There is no.*Schema` with id 4/,
      [left: [1, 2, 3], right: 4],
      fn -> 
        Steps.assert_id_inserted(:running, :inserted_value)
      end)
  end
  
  test "the id was already there" do
    stub_history(
      existing_ids: [1, 2, 3],
      inserted_value: %{id: 3})
    stub(existing_ids_with: fn _ -> "irrelevant" end)

    assertion_fails(~r/Before the insertion, there already was a.*Schema` with id 3/,
      [left: [1, 2, 3], right: 3],
      fn -> 
        Steps.assert_id_inserted(:running, :inserted_value)
      end)
  end
end
