defmodule Run.ValidationStep.AsCastTest do
  use TransformerTestSupport.Case
  use T.Drink.AndRun
  alias Run.Steps
  use Mockery
  import T.RunningStubs
  alias Ecto.Changeset

  setup do
    stub(workflow_name: :success, name: :example,
      validation_changeset_checks: [],
      field_calculators: [])
    :ok
  end

  defmodule Schema do
    use Ecto.Schema
    alias Ecto.Changeset
    schema "bogus" do
      field :age, :integer
      field :date, :date
    end
    def changeset(struct, params), do: Changeset.cast(struct, params, [:age, :date])
  end

  defp run([field, {:params, params}, {:cast_to, cast_value}, {:changes, changes}]) do
    changeset = ChangesetX.valid_changeset(changes: changes)
    stub_history(params: params, make_changeset: changeset)
    stub(as_cast: AsCast.new(Schema, [field]))
    given Schema.changeset(%Schema{}, params), return: cast_value
    Steps.check_validation_changeset(:running, :make_changeset)
  end

  defp pass(setup), do: assert run(setup) == :uninteresting_result

  test "as_cast is used" do
    passes = 
      [:age, params: %{"age" => "6"}, cast_to: 6, changes: %{age: 6}]
    fails = 
      [:age, params: %{"age" => "6"}, cast_to: 6, changes: %{age: 7}]

    pass(passes)

    assertion_fails(~r/Example `:example`: Field `:age` has the wrong value/, 
      [message: ~r/Changeset:.*age: 7/,
       expr: [[as_cast: [:age]],
              "expanded to",
              [changeset: [{:changes, [age: 6]}, "..."]]],
       left: 7,
       right: 6],
      fn ->
        run(fails)
      end)
  end

  test "the desired parameter can be missing from the changeset" do
    passes = 
      [:age, params: %{}, cast_to: 6, changes: %{}]

    pass(passes)
  end

  test "If the `cast` produces an error, that's checked" do
    stub(as_cast: AsCast.new(Schema, [:date]), workflow_name: :validation_error)
    stub_history(params: %{"date" => "2001-0"})

    changeset =
      Schema.changeset(%Schema{}, %{"age" => "6"})
      |> Changeset.add_error(:date, "the wrong error message")
    stub_history(make_changeset: changeset)
    
    assertion_fails(~r/Example `:example`: Field :date does not have a matching error message/, 
      [expr: [[as_cast: [:date]],
              "expanded to",
              [changeset: [{:errors, [date: "is invalid"]}, "..."]]],
       left: ["the wrong error message"],
       right: "is invalid"],
      fn ->
        Steps.check_validation_changeset(:running, :make_changeset)
      end)
  end
end
