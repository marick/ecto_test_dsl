defmodule Link.ChangesetNotationToAssertionTest do
  use TransformerTestSupport.Drink.Me
  alias T.Link.ChangesetNotationToAssertion, as: Translate
  alias Ecto.Changeset
  use T.Case

  describe "creation and running" do
    test "a symbol" do 
      assertion = Translate.from(:valid)
      
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
      assertion = Translate.from({:changes, [a: "a", b: "b"]})

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
      [valid, changes] = Translate.from([:valid, changes: [a: "a", b: "b"]])
      
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
