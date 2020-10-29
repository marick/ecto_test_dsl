defmodule Variants.EctoClassic.FieldTransformationErrorTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Variants.EctoClassic

  defmodule Schema do 
    use Ecto.Schema
    import Ecto.Changeset

    embedded_schema do
      field :date_string, :string, virtual: true
      field :date, :date
      field :days_since_2000, :integer
    end

    def changeset(struct, params) do
      struct
      |> cast(params, [:date_string])
      |> validate_required([:date_string])
      |> calculate_date
      |> count_the_days
    end

    def calculate_date(changeset) do 
      put_change(changeset, :date, Date.from_iso8601!(changeset.changes.date_string))
    end

    def count_the_days(changeset) do
      days = Date.diff(changeset.changes.date, ~D[2000-01-01])
      put_change(changeset, :days_since_2000, days)
    end
  end

  defmodule Examples do
    use TransformerTestSupport.Variants.EctoClassic

    def create_test_data do
      start(
        module_under_test: Schema,
        format: :phoenix
      ) |>

      field_transformations(
        as_cast: [:date_string],
        date: on_success(
          &Date.from_iso8601!/1, applied_to: :date_string),
        days_since_2000: on_success(
          &Date.diff/2, applied_to: [:date, ~D[2001-01-01]]))
          #                                       ^typo
          |> 
      
      category(:success,
        ok: [params: [date_string:      "2000-01-04"]],
        blow_up: [params: [date_string: "2000-01-0"],
                  changeset: [error: [date_string: ~r/invalid/]]]
      )
    end
  end

  test "workflows" do
    assertion_fails(~r/`:days_since_2000`.*~D\[2001-01-01]/,
      [left: 3, right: -363],
      fn ->
        Examples.Tester.check_workflow(:ok)
      end)

    assert_raise(ArgumentError, fn -> 
      Examples.Tester.check_workflow(:blow_up)
    end)
  end
end
