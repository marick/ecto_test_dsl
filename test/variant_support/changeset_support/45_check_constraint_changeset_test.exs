defmodule VariantSupport.Changeset.CheckConstraintChangesetTest do
  use TransformerTestSupport.Case
  use T.Drink.AndRun
  alias T.Run.Steps
  alias T.Sketch
  alias Ecto.Changeset
  use T.Parse.All

  defmodule Schema do
    use Ecto.Schema

    embedded_schema do
      field :date_string, :string, default: "today"
      field :date, :date
      field :lock_uuid, Ecto.UUID
    end
  end

  def run(example, result) do
    %RunningExample{example: example, history: History.trivial(step: result)}
    |> Steps.check_constraint_changeset(:step)
  end

  # ----------------------------------------------------------------------------

  @example Sketch.example(:name, :constraint_error, [
        constraint_changeset(error: [name: ~r/duplicate/])])
  
  test "an acceptable error changeset" do
    changeset =
      Changeset.change(%Schema{})
      |> Changeset.add_error(:name, "is a duplicate")

    assert run(@example, {:error, changeset}) == :uninteresting_result
  end

  test "a missing error" do
    changeset =
      Changeset.change(%Schema{})
    
    assertion_fails(~r/There are no errors for field `:name`/,
      fn ->
        run(@example, {:error, changeset})
      end)
  end

  @tag :skip
  test "an additional error" do
    changeset =
      Changeset.change(%Schema{})
      |> Changeset.add_error(:name, "is a duplicate")
      |> Changeset.add_error(:lock_uuid, "is stolen")

    assertion_fails(~r/There is an unexpected error for field `:lock_uuid`/,
      fn ->
        run(@example, {:error, changeset})
      end)
  end

  @tag :skip
  test "can use a reference to a previously-added example" do
  end

end
