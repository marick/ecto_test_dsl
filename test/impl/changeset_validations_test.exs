defmodule Impl.ChangesetValidationsTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl.{Validations,Messages}
  import FlowAssertions.AssertionA
  import FlowAssertions.Define.Tabular
  alias Ecto.Changeset

  describe "validity test" do

    test "foo" do
      valid = &(%Changeset{valid?: &1})
      category = &(%{categories: [&1]}) # Produces an example.

      a = assertion_runners_for(fn changeset, example ->
        Validations.validate_changeset_against_example(
          changeset, :some_example_name, example)
      end)

      [valid.( true  ), category.(  :valid   )] |> a.pass.()
      [valid.( false ), category.(  :valid   )] 
        |> a.fail.(Messages.should_be_valid(:some_example_name))
        |> a.plus.(left: valid.(false))

      [valid.( true  ), category.(  :invalid )]
        |> a.fail.(Messages.should_be_invalid(:some_example_name))
        |> a.plus.(left: valid.(true))
      [valid.( false ), category.(  :invalid )] |> a.pass.()

      # If there is neither valid nor invalid, no check is done.
      [valid.( true  ), category.(  :other   )] |> a.pass.()
      [valid.( false ), category.(  :other   )] |> a.pass.()
    end
  end
end
