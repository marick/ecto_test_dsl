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
      field :ref_id, :id
    end
  end
  

  setup do
    stub(name: :example, neighborhood: %{})
    :ok
  end

  IO.inspect "This is pending"

  # defp run([checks, changeset]) do
  #   stub_history(try_changeset_insertion: {:error, changeset})
  #   stub(constraint_changeset_checks: checks)
  #   Steps.check_constraint_changeset(:running, :try_changeset_insertion)
  # end

  # defp pass(setup), do: assert run(setup) == :uninteresting_result

  

  # test "user assertions are exercised" do
  #   changeset =
  #     Changeset.change(%Schema{}, %{name: "fred"})
  #     |> Changeset.add_error(:name, "duplicate name")

  #   passes = [change: [name: "fred"], error: [name: "duplicate name"]]
  #   fails = [change: [name: "fred"], error: [name:  "Dduplicate name"]]

  #   [passes, changeset] |> pass()

    
  #   assertion_fails(~r/Example `:example`/,
  #     [message: ~r/Field :name does not have a matching error message/,
  #      left:  ["duplicate name"],
  #      right: "Dduplicate name"],
  #     fn ->
  #       [fails, changeset] |> run()
  #     end)
  # end

  # test "missing fields" do # just for the heck of it"
  #   changeset =
  #     Changeset.change(%Schema{}, %{name: "fred", other: "3"})
  #     |> Changeset.add_error(:name, "duplicate name")

  #   fails = [change: [name: "fred", other: "3"],
  #            error: [other: "other message"]]
                     
  #   assertion_fails(~r/Example `:example`/,
  #     [message: ~r/There are no errors for field `:other`/,
  #      expr: [changeset: [{:error, [other: "other message"]}, "..."]]],
  #     fn ->
  #       [fails, changeset] |> run()
  #     end)
  # end
  
  # test "references to neighbors are supported" do
  #   other_een = een(:other_example)
  #   stub(neighborhood: %{other_een => %{id: 333}})

  #   checks = [change: [name: "fred", ref_id: FieldRef.new(id: other_een)],
  #             error: [ref_id: "some message"]]

  #   make_changeset = fn ref_id -> 
  #     Changeset.change(%Schema{}, %{name: "fred", ref_id: ref_id})
  #     |> Changeset.add_error(:ref_id, "some message")
  #   end

  #   passes = [checks, make_changeset.(333)]
  #   fails =  [checks, make_changeset.("NOT")]

  #   passes |> pass()

  #   assertion_fails(~r/Example `:example`/,
  #     [message: ~r/Field `:ref_id` has the wrong value/,
  #      message: ~r/Changeset:.*ref_id: "NOT"}/,
  #      expr: [changeset: [{:change, [{:name, "fred"}, {:ref_id, 333}]}, "..."]],
  #      left: "NOT",
  #      right: 333],
  #     fn ->
  #       run(fails)
  #     end)
  # end
end
