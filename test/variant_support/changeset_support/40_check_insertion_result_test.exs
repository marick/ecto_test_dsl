defmodule VariantSupport.Changeset.CheckInsertionResultTest do
  use TransformerTestSupport.Case
  use T.Drink.AndRun
  alias T.Run.Steps
  alias T.Sketch
  alias Ecto.Changeset

  def run(example, result) do 
    %RunningExample{example: example, history: History.trivial(step: result)}
    |> Steps.check_insertion_result(:step)
  end

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
