defmodule Run.Support.ChangesetAssertionsTest do
  use EctoTestDSL.Case
  alias T.Run.ChangesetAssertions
  alias Ecto.Changeset

  describe "creation and running" do
    test "a symbol" do 
      assertion = ChangesetAssertions.from(:valid)
      
      valid = %Changeset{valid?: true}
      assert assertion.(valid) == :ok

      invalid = %Changeset{valid?: false}

      assertion_fails("The changeset is invalid",
        [expr: [changeset: [:valid, "..."]]],
        fn ->
          assertion.(invalid)
        end)
    end

    test "a symbol plus arg" do
      assertion = ChangesetAssertions.from({:changes, [a: "a", b: "b"]})

      changeset  = fn changes -> %Changeset{changes: changes} end

      ok = changeset.(%{a: "a", b: "b"})
      assert assertion.(ok) == :ok

      wrong = changeset.(%{a: "a", b: 3})
      assertion_fails("Field `:b` has the wrong value",
        [left: 3, right: "b",
         expr: [changeset: [{:changes, [a: "a", b: "b"]}, "..."]]],
        fn ->
          assertion.(wrong)
        end)
    end

    test "list" do
      [valid, changes] = ChangesetAssertions.from([:valid, changes: [a: "a", b: "b"]])
      
      assertion_fails("The changeset is invalid",
        fn ->
          valid.(ChangesetX.invalid_changeset(changes: %{}))
        end)

      assertion_fails("Field `:b` has the wrong value",
        [left: 3, right: "b",
         expr: [changeset: [{:changes, [a: "a", b: "b"]}, "..."]]],
        fn ->
          changes.(ChangesetX.valid_changeset(changes: %{a: "a", b: 3}))
        end)

    end      
  end
end 
