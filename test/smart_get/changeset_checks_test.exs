defmodule SmartGet.ChangesetChecksTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.SmartGet.ChangesetChecks, as: Checks
  import TransformerTestSupport.Build

  # ----------------------------------------------------------------------------
  describe "valid/invalid additions" do 
    test "a :validation_failure category has an `invalid` check put at the front" do
      test_data =
        TestBuild.one_category(:validation_failure,
          [],
          oops: [changeset(no_changes: [:date])])
      
      Checks.get(test_data, :oops)
      |> assert_equal([:invalid, {:no_changes, [:date]}])
    end
    
    
    test "any other category gets a `valid` check" do
      test_data =
        TestBuild.one_category(:some_category_name,
          [],
          ok: [changeset(no_changes: [:date])])
      
      Checks.get(test_data, :ok)
      |> assert_equal([:valid, {:no_changes, [:date]}])
    end
    
    test "checks are added even if there's no changest" do
      test_data =
        TestBuild.one_category(
          [],
          ok: [])
      
      Checks.get(test_data, :ok)
      |> assert_equal([:valid])
    end
  end

  # ----------------------------------------------------------------------------
  defmodule AsCast do 
    use Ecto.Schema
    embedded_schema do
      field :name, :string
      field :date, :date
      field :other, :string
      field :other2, :string
    end
  end

  describe "adding an automatic as_cast test" do
    test "starting with nothing" do 
      test_data =
        TestBuild.one_category(
          [module_under_test: AsCast,
           field_transformations: [as_cast: [:date]]
          ],
          ok: [params(date: "2001-01-01")])

      Checks.get(test_data, :ok)
      |> assert_equal([:valid, changes: [date: ~D[2001-01-01]]])
    end

    test "starting with something" do 
      test_data =
        TestBuild.one_category(
          [module_under_test: AsCast,
           field_transformations: [as_cast: [:date]]
          ],
          ok: [params(date: "2001-01-01"),
               changeset(changes: [name: "Bossie"])
              ])

      Checks.get(test_data, :ok)
      |> assert_equal([:valid,
                      changes: [name: "Bossie"],
                      changes: [date: ~D[2001-01-01]]])
    end

    test "it is OK for a parameter to be missing" do
      test_data =
        TestBuild.one_category(
          [module_under_test: AsCast,
           field_transformations: [as_cast: [:other]]
          ],
          ok: [params(date: "2001-01-01"),
               changeset(changes: [name: "Bossie"])
              ])

      Checks.get(test_data, :ok)
      |> assert_equal([:valid,
                      changes: [name: "Bossie"],
                      no_changes: [:other]])
    end

    test "errors" do
      test_data =
        TestBuild.one_category(:validation_failure,
          [module_under_test: AsCast,
           field_transformations: [as_cast: [:date, :name]]
          ],
          bad_date: [params(date: "2001-01-0", name: "Bossie")])

      Checks.get(test_data, :bad_date)
      |> assert_equal([:invalid,
                      changes: [name: "Bossie"],
                      no_changes: [:date],
                      errors: [date: "is invalid"]])
    end

    test "user values override" do 
      test_data =
        TestBuild.one_category(
          [module_under_test: AsCast,
           field_transformations: [as_cast: [:date]]
          ],
          ok: [params(date: "2001-01-01"),
               changeset(no_changes: :date)
              ])

      Checks.get(test_data, :ok)
      |> assert_equal([:valid, no_changes: :date])
    end


    test "overriding just one of the check types prevents all additions" do 
      test_data =
        TestBuild.one_category(
          [module_under_test: AsCast,
           field_transformations: [as_cast: [:date]]
          ],
          bad_date: [params(date: "2001-01-0"), # note this is in error.
                     changeset(changes: [date: ~D[2001-01-01]]) # so this is inappropriate
                    ])

      Checks.get(test_data, :bad_date)
      |> assert_equal([:valid, changes: [date: ~D[2001-01-01]]])
      # However, the inappropriate check is obeyed.
    end
    
  end

  # ----------------------------------------------------------------------------
  defmodule OnSuccess do 
    use Ecto.Schema
    embedded_schema do
      field :date_string, :string, virtual: true
      field :date, :date
    end
  end

  describe "adding an on_success conversion" do
    @on_success_common_args [
      module_under_test: OnSuccess,
      field_transformations: [
        as_cast: [:date_string],
        date: on_success(&Date.from_iso8601!/1, applied_to: :date_string)
      ]
    ]

    @tag :skip
    test "starting with nothing" do 
      test_data =
        TestBuild.one_category(@on_success_common_args,
          ok: [params(date_string: "2001-01-01")])

      Checks.get(test_data, :ok)
      |> assert_equal([
        :valid,
        changes: [date_string: "2001-01-01"],
        changes: [date: ~D[2001-01-01]]])
    end
  end
end 
