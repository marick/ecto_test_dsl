defmodule VariantSupport.Changeset.CheckConstraintChangesetTest do
  alias TransformerTestSupport, as: T
  use T.Case
  alias T.Build
  alias T.VariantSupport.ChangesetSupport
  alias T.Sketch
  alias T.RunningExample
  alias T.RunningExample.History
  alias Ecto.Changeset

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
    |> ChangesetSupport.check_constraint_changeset(:step)
  end

  # ----------------------------------------------------------------------------

  @example Sketch.example(:name, :constraint_error, [
        Build.constraint_changeset(error: [name: ~r/duplicate/])])
  
  test "unexpected :ok" do
    assertion_fails(~r/Example `:name`: Expected an error tuple/,
      [left: {:ok, "return value"}],
      fn ->
        run(@example, {:ok, "return value"})
      end)
  end

  test "an acceptable error changeset" do
    changeset =
      Changeset.change(%Schema{})
      |> Changeset.add_error(:name, "is a duplicate")

    assert run(@example, {:error, changeset}) == changeset
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
