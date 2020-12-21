defmodule Link.ChangesetNotationToAssertionTest do
  use TransformerTestSupport.Drink.Me
  alias T.Link.ChangesetNotationToAssertion, as: Translate
  alias Ecto.Changeset
  alias FlowAssertions.Ecto.ChangesetA
  use T.Case
  alias T.Sketch

  describe "creation and running" do
    test "a symbol" do 
      assertion = Translate.from(:valid)
      assert assertion.from == :valid
      
      valid = %Changeset{valid?: true}
      assert Translate.check(assertion, valid) == :ok

      
      invalid = %Changeset{valid?: false}

      assertion_fails("The changeset is invalid",
        [expr: [changeset: [:valid, "..."]]],
        fn ->
          Translate.check(assertion, invalid) == :ok
        end)
    end

    test "a symbol plus arg" do
      assertion = Translate.from({:changes, [a: "a", b: "b"]})
      assert assertion.from == {:changes, [a: "a", b: "b"]}

      check  = fn changes ->
        changeset = %Changeset{changes: changes}
        Translate.check(assertion, changeset)
      end

      assert check.(%{a: "a", b: "b"}) == :ok


      assertion_fails("Field `:b` has the wrong value",
        [left: 3, right: "b",
         expr: [changeset: [{:changes, [a: "a", b: "b"]}, "..."]]],
        fn ->
          check.(%{a: "a", b: 3})
        end)
    end

    test "list" do
      [valid, changes] = Translate.from([:valid, changes: [a: "a", b: "b"]])
      
      assertion_fails("The changeset is invalid",
        fn ->
          valid.runner.(Sketch.invalid_changeset(changes: %{}))
        end)

      assertion_fails("Field `:b` has the wrong value",
        [left: 3, right: "b"],
        fn ->
          changes.runner.(Sketch.valid_changeset(changes: %{a: "a", b: 3}))
        end)

    end      
  end
end 
