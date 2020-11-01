defmodule VariantSupport.Changeset.CheckInsertionResultTest do
  alias TransformerTestSupport, as: T
  use T.Case
  alias T.VariantSupport.Changeset, as: ChangesetS
  alias T.Sketch
  alias Ecto.Changeset

  def run(example, result),
    do: ChangesetS.check_insertion_result(result, example)

  # ----------------------------------------------------------------------------
  test "handling of ok/error" do
    example = Sketch.example(:name, :success)

    run(example, {:ok, :ignored}) # no assertion failure

    changeset =
      %Changeset{valid?: false} |>
      Changeset.add_error(:date, "error message")

    assertion_fails(~r/Example `:name`: Unexpected insertion failure/,
      [left: [date: {"error message", []}]],
      fn ->
        run(example, {:error, changeset})
      end)
  end
end
