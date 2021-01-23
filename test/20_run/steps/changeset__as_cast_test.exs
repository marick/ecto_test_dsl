defmodule Run.Steps.AsCastTest do
  use TransformerTestSupport.Case
  use T.Drink.AndRun
  alias Run.Steps
  use Mockery
  import T.RunningStubs
  alias Ecto.Changeset

  setup do
    stub(name: :example,
      validation_changeset_checks: [],
      neighborhood: %{})
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
    stub_history(params: params, changeset_from_params: changeset)
    stub(as_cast: AsCast.new(Schema, [field]))
    given Schema.changeset(%Schema{}, params), return: cast_value
    Steps.as_cast_checks(:running, :changeset_from_params)
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
    stub(as_cast: AsCast.new(Schema, [:date]))
    stub_history(params: %{"date" => "2001-0"})

    changeset =
      Schema.changeset(%Schema{}, %{"age" => "6"})
      |> Changeset.add_error(:date, "the wrong error message")
    stub_history(changeset_from_params: changeset)
    
    assertion_fails(~r/Example `:example`: Field :date does not have a matching error message/, 
      [expr: [[as_cast: [:date]],
              "expanded to",
              [changeset: [{:errors, [date: "is invalid"]}, "..."]]],
       left: ["the wrong error message"],
       right: "is invalid"],
      fn ->
        Steps.as_cast_checks(:running, :changeset_from_params)
      end)
  end

  test "a user assertion overrides `as_cast`" do
    stub(as_cast: AsCast.new(Schema, [:age]))
    stub_history(params: %{"age" => "5858"})   # Cast value will be ignored
    # ... in favor of:
    stub(validation_changeset_checks: [changes:  [age: 0]])

    stub_history(changeset_from_params: ChangesetX.valid_changeset([changes: %{age: 0}]))

    assert Steps.as_cast_checks(:running, :changeset_from_params) == :uninteresting_result
  end
  
  test "but other as_cast values are checked" do
    stub(as_cast: AsCast.new(Schema, [:age, :date]))
    stub_history(params: %{"age" => "5858", "date" => "2001-1"})
    stub(validation_changeset_checks: [changes:  [age: 0]])

    changeset =
      Schema.changeset(%Schema{}, %{"age" => "6"})
      |> Changeset.add_error(:date, "the wrong error message")
    stub_history(changeset_from_params: changeset)

    assertion_fails(~r/Example `:example`: Field :date does not have a matching error message/, 
      [expr: [[as_cast: [:date]],
              "expanded to",
              [changeset: [{:errors, [date: "is invalid"]}, "..."]]],
       left: ["the wrong error message"],
       right: "is invalid"],
      fn ->
        Steps.as_cast_checks(:running, :changeset_from_params)
      end)
  end
  
end
