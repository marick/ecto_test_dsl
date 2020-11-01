defmodule VariantSupport.Changeset.CheckConstraintChangesetTest do
  alias TransformerTestSupport, as: T
  use T.Case
  alias T.VariantSupport.Changeset, as: ChangesetS
  alias T.Sketch
#  alias Ecto.Changeset

  def run(example, result),
    do: ChangesetS.check_constraint_changeset(result, example)

  # ----------------------------------------------------------------------------
  test "unexpected :ok" do
    example = Sketch.example(:name, :constraint_error)

    assertion_fails(~r/Example `:name`: Expected an error tuple/,
      [left: {:ok, "return value"}],
      fn ->
        run(example, {:ok, "return value"})
      end)
  end
end
