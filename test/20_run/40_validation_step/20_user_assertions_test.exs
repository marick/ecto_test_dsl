defmodule Run.ValidationStep.UserChecksTest do
  use TransformerTestSupport.Case
  use T.Drink.AndRun
  alias Run.Steps
  use Mockery
  import T.RunningStubs

  setup do
    stub(workflow_name: :success, name: :example,
      as_cast: AsCast.nothing,
      field_calculators: [],
      neighborhood: %{})
    stub_history(params: %{})
    :ok
  end

  defp run([checks, changeset]) do 
    stub_history(make_changeset: changeset)
    stub(validation_changeset_checks: checks)
    Steps.check_validation_changeset(:running, :make_changeset)
  end

  defp pass(setup), do: assert run(setup) == :uninteresting_result

  test "expected changes" do
    [                          [changes:  [name: "Bossie"]],
     ChangesetX.valid_changeset(changes: %{name: "Bossie"})] |> pass()
  end
    
  test "expected change is missing" do
    setup = [                          [changes:  [name: "Bossie", age: 12]],
             ChangesetX.valid_changeset(changes: %{name: "Bossie"})]
    assertion_fails(~r/Example `:example`/,
      [message: ~r/Field `:age` is missing/,
       message: ~r/Changeset:.*changes: %{name: "Bossie"}/,
       expr: [changeset: [{:changes, [name: "Bossie", age: 12]}, "..."]],
       left: %{name: "Bossie"},
       right: [name: "Bossie", age: 12]],
      fn ->
        run(setup)
      end)
  end

  test "error cases are fine" do
    stub(workflow_name: :validation_error)   # overrides

    [                            [changes:  [name: "Bossie"]],
     ChangesetX.invalid_changeset(changes: %{name: "Bossie"})] |> pass()
  end


  test "empty check list is" do
    [                          [                          ],
     ChangesetX.valid_changeset(changes: %{name: "Bossie"})] |> pass()
  end

  test "references to neighbors are supported" do
    other_een = een(:other_example)
    stub(neighborhood: %{other_een => %{id: 333}})

    checks = [changes: [ref_id: FieldRef.new(id: other_een)]]
    passes = [checks, ChangesetX.valid_changeset(changes: %{ref_id: 333})]
    fails =  [checks, ChangesetX.valid_changeset(changes: %{ref_id: "NOT"})]

    passes |> pass()

    assertion_fails(~r/Example `:example`/,
      [message: ~r/Field `:ref_id` has the wrong value"/,
       message: ~r/Changeset:.*changes: %{ref_id: "NOT"}/,
       expr: [changeset: [{:changes, [ref_id: 333]}, "..."]],
       left: "NOT",
       right: 333],
      fn ->
        run(fails)
      end)
    
  end
  
end
