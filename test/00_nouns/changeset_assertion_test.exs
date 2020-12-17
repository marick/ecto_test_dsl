defmodule Nouns.ChangesetAssertionTest do
  use TransformerTestSupport.Drink.Me
  alias T.Nouns.ChangesetAssertion
  alias Ecto.Changeset
  alias FlowAssertions.Ecto.ChangesetA
  use T.Case

  describe "creation and running" do
    test "a symbol" do 
      assertion = ChangesetAssertion.from(:valid)
      assert assertion.from == :valid
      
      valid = %Changeset{valid?: true}
      assert ChangesetAssertion.check(assertion, valid) == :ok

      invalid = %Changeset{valid?: false}    
      assertion_fails("The changeset is invalid",
        fn ->
          ChangesetAssertion.check(assertion, invalid) == :ok
        end)
    end

    test "a symbol plus arg" do 
      assertion = ChangesetAssertion.from({:changes, [a: "a", b: "b"]})
      assert assertion.from == {:changes, [a: "a", b: "b"]}

      check  = fn changes ->
        changeset = %Changeset{changes: changes}
        ChangesetAssertion.check(assertion, changeset)
      end

      assert check.(%{a: "a", b: "b"}) == :ok
      
      assertion_fails("Field `:b` has the wrong value",
        [left: 3, right: "b"],
        fn ->
          check.(%{a: "a", b: 3})
        end)
    end
  end

  test "raw version" do
    assertion =
      ChangesetAssertion.from(
        fn changeset -> ChangesetA.assert_valid(changeset) end,
        "from")
    assert assertion.from == "from"
      
    valid = %Changeset{valid?: true}
    assert ChangesetAssertion.check(assertion, valid) == :ok
    
    invalid = %Changeset{valid?: false}    
    assertion_fails("The changeset is invalid",
      fn ->
        ChangesetAssertion.check(assertion, invalid) == :ok
      end)
  end
end 
