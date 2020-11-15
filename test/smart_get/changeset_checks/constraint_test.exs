defmodule SmartGet.ChangesetChecks.ConstraintTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.SmartGet.ChangesetChecks, as: Checks
  alias TransformerTestSupport.SmartGet.Example
  import TransformerTestSupport.Build

  defmodule AsCast do 
    use Ecto.Schema
    schema "table" do
      field :name, :string
      field :date, :date
      field :other, :string
      field :other2, :string

      field :species_id, :integer   # Faking a `belongs_to`
    end
  end

  describe "has no effect" do
    defp as_cast_data(fields, example_descriptions, category_opts) do 
      TestBuild.one_category(
        Keyword.get(category_opts, :category),
        [module_under_test: AsCast,
         field_transformations: [as_cast: fields]
          ],
        example_descriptions)
    end

    # Assumes example to be tested is `:example`
    defp run_example(fields, example_opts,
      category_opts \\ [category: :validation_success]) do
        
      as_cast_data(fields, [example: example_opts], category_opts)
      |> Example.get(:example)
      |> Checks.get_constraint_checks(previously: %{})
    end

    test "starting with no existing checks" do
      run_example([:date], [params(         date:   "2001-01-01")])
      |> assert_equal([])
    end

    test "starting with existing checks" do
      run_example([:date], [params(date: "2001-01-01"),
                            constraint_changeset(changes: [name: "Bossie"])])
      |> assert_equal(changes: [name: "Bossie"])
    end
  end 
end
