defmodule Run.ConstraintStep.UserAssertionsTest do
  use TransformerTestSupport.Case
  use T.Drink.AndRun
  alias Run.Steps
  use Mockery
  import T.RunningStubs
  alias Ecto.Changeset

  defmodule Schema do
    use Ecto.Schema
    alias Ecto.Changeset
    schema "bogus" do 
      field :name, :string
      field :other, :string
    end
  end
  

  setup do
    stub(name: :example)
    :ok
  end

  defp run([checks, changeset]) do
    stub_history(insert_changeset: {:error, changeset})
    stub(constraint_changeset_checks: checks)
    Steps.check_constraint_changeset(:running, :insert_changeset)
  end

  defp pass(setup), do: assert run(setup) == :uninteresting_result

  

  test "user assertions are exercised" do
    changeset =
      Changeset.change(%Schema{}, %{name: "fred"})
      |> Changeset.add_error(:name, "duplicate name")

    passes = [change: [name: "fred"], error: [name: "duplicate name"]]
    fails = [change: [name: "fred"], error: [name:  "Dduplicate name"]]

    [passes, changeset] |> pass()

    
    assertion_fails(~r/Example `:example`/,
      [message: ~r/Field :name does not have a matching error message/,
       left:  ["duplicate name"],
       right: "Dduplicate name"],
      fn ->
        [fails, changeset] |> run()
      end)
  end

  test "missing fields" do # just for the heck of it"
    changeset =
      Changeset.change(%Schema{}, %{name: "fred", other: "3"})
      |> Changeset.add_error(:name, "duplicate name")

    fails = [change: [name: "fred", other: "3"],
             error: [other: "other message"]]
                     
    assertion_fails(~r/Example `:example`/,
      [message: ~r/There are no errors for field `:other`/,
       expr: [changeset: [{:error, [other: "other message"]}, "..."]]],
      fn ->
        [fails, changeset] |> run()
      end)
  end
  
end
