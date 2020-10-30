defmodule Variants.EctoClassic.SuccessCategoryTest do
  use TransformerTestSupport.Case
#  import FlowAssertions.AssertionA
  
  use TransformerTestSupport.Variants.EctoClassic
  alias TransformerTestSupport.SmartGet

  defmodule Species do
    use Ecto.Schema

    schema "bogus" do 
      field :name, :string
    end
  end

  defmodule Schema do 
    use Ecto.Schema
    import Ecto.Changeset

    schema "bogus" do
      field :age, :integer
      field :date_string, :string, virtual: true
      field :date, :date
      field :days_since_2000, :integer
      belongs_to :species, Species
      field :optional_comment, :string
      field :defaulted_comment, :string, default: "no comment"
    end

    def fields_to_cast, do: [:age, :date_string, :species_id,
                             :optional_comment, :defaulted_comment]
    def required_fields, do: [:date_string, :age, :species_id]

    def changeset(struct, params) do
      struct
      |> cast(params, fields_to_cast())
      |> validate_required(required_fields())
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
        as_cast: Schema.fields_to_cast(),
        date: on_success(Date.from_iso8601!(:date_string)),
        days_since_2000: on_success(Date.diff(:date, ~D[2000-01-01]))
      ) |>

      category(:success,
        only_required: [
          params(age: 55, date_string: "2000-01-02", species_id: 1)
        ], 
        complete: [
          params_like(:only_required, except: [
                optional_comment: "optional comment",
                defaulted_comment: "defaulted comment override"
        ])]
      )
    end
  end

  @tag :skip
  test "Have params_like accept a `deleting` option so that `only_required` can be derived from `complete`."

  test "params step" do
    Examples.Tester.params(:complete)
    |> assert_same_map(%{
          "age" => "55",
          "date_string" => "2000-01-02",
          "species_id" => "1",
          "defaulted_comment" => "defaulted comment override",
          "optional_comment" => "optional comment"})

    Examples.Tester.params(:only_required)
    |> assert_same_map(%{
          "age" => "55",
          "date_string" => "2000-01-02",
          "species_id" => "1"})
  end

  describe "validation step" do
    test "fetching changeset" do
      only_required_changeset = Examples.Tester.validation_changeset(:only_required)

      only_required_changes = %{
        age: 55,
        date_string: "2000-01-02",
        date: ~D[2000-01-02],
        days_since_2000: 1,
        species_id: 1
      }
      
      only_required_changeset
      |> assert_valid
      |> assert_changes(only_required_changes)

      complete_changeset = Examples.Tester.validation_changeset(:complete)

      complete_changes =
        Map.merge(only_required_changes, %{
              optional_comment: "optional comment",
              defaulted_comment: "defaulted comment override"})
      
      complete_changeset
      |> assert_valid
      |> assert_changes(complete_changes)
    end
    
    test "happens if changeset is valid" do
      Examples.Tester.check_workflow(:complete)
      Examples.Tester.check_workflow(:only_required)
    end
  end
end
