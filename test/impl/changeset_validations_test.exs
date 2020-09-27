defmodule Impl.ChangesetValidationsTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl.{Validations,Messages}
  import FlowAssertions.AssertionA
  import FlowAssertions.Define.Tabular
  alias Ecto.Changeset

  test "common message handling" do
    assertion_fails(
      ~r/.*/, #Field `:a` has the wrong value/,  # The base message
      # and surrounding messages
      [message: ~r/Example `:some_example_name`/,
       message: ~r/Field `:a` has the wrong value/,
       message: ~r/Changeset: /],
      fn ->
        Validations.validate_changeset_against_example(
          %Changeset{changes: %{a: 1}},
          :some_example_name,
          %{changeset: [changes: [a: 2]]})
      end)
  end

  test "valid? field" do
    valid = &(%Changeset{valid?: &1})
    category = &(%{categories: [&1]}) # Produces an example.

    a = assertion_runners_for(fn changeset, example ->
      Validations.assert_validity(changeset, :some_example_name, example)
    end)

    [valid.( true  ), category.(  :valid   )] |> a.pass.()
    [valid.( false ), category.(  :valid   )] |> a.fail.(
      message: Messages.should_be_valid(:some_example_name), 
      left: valid.(false))

    [valid.( true  ), category.(  :invalid )] |> a.fail.(
      message: Messages.should_be_invalid(:some_example_name),
      left: valid.(true))
    [valid.( false ), category.(  :invalid )] |> a.pass.()

    # If there is neither valid nor invalid, no check is done.
    [valid.( true  ), category.(  :other   )] |> a.pass.()
    [valid.( false ), category.(  :other   )] |> a.pass.()
  end
  
  describe "changeset" do
    setup do 
      a = assertion_runners_for(fn changeset, example ->
        Validations.assert_changeset(changeset, :some_example_name, example)
      end)
      [a: a]
    end
    
    test "changes explicitly", %{a: a} do
      actual = &(%Changeset{changes: &1})
      checkable = &(%{changeset: [changes: &1]})
      
      [actual.(%{value: 1}), checkable.(value: 1)] |> a.pass.()
      [actual.(%{value: 1}), checkable.(value: 2)] |> a.fail.(
        message: ~r/Field `:value` has the wrong value/,
        left: 1, right: 2)
    end

    test "you can use single-valued assertions" do
      assertion_fails("The changeset is invalid",
        fn -> 
          Validations.assert_changeset(
            %Changeset{valid?: false},
            :some_example_name,
            %{changeset: [valid: true]})
        end)
    end
  end
end
