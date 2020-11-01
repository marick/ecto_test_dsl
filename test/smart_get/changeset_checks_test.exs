defmodule SmartGet.ChangesetChecksTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.SmartGet.ChangesetChecks, as: Checks
  import TransformerTestSupport.Build
  alias Ecto.Changeset

  # ----------------------------------------------------------------------------
  describe "valid/invalid additions" do 
    test "a :validation_error category has an `invalid` check put at the front" do
      test_data =
        TestBuild.one_category(:validation_error,
          [],
          oops: [changeset(no_changes: [:date])])
      
      Checks.get(test_data, :oops, :validation)
      |> assert_equal([:invalid, {:no_changes, [:date]}])
    end
    
    
    test "any other category gets a `valid` check" do
      test_data =
        TestBuild.one_category(:some_category_name,
          [],
          ok: [changeset(no_changes: [:date])])
      
      Checks.get(test_data, :ok, :validation)
      |> assert_equal([:valid, {:no_changes, [:date]}])
    end
    
    test "checks are added even if there's no changest" do
      test_data =
        TestBuild.one_category(
          [],
          ok: [])
      
      Checks.get(test_data, :ok, :validation)
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

      Checks.get(test_data, :ok, :validation)
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

      Checks.get(test_data, :ok, :validation)
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

      Checks.get(test_data, :ok, :validation)
      |> assert_equal([:valid,
                      changes: [name: "Bossie"],
                      no_changes: [:other]])
    end

    test "errors" do
      test_data =
        TestBuild.one_category(:validation_error,
          [module_under_test: AsCast,
           field_transformations: [as_cast: [:date, :name]]
          ],
          bad_date: [params(date: "2001-01-0", name: "Bossie")])

      Checks.get(test_data, :bad_date, :validation)
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

      Checks.get(test_data, :ok, :validation)
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

      Checks.get(test_data, :bad_date, :validation)
      |> assert_equal([:valid, changes: [date: ~D[2001-01-01]]])
      # However, the inappropriate check is obeyed.
    end
    
    @tag :skip
    test "no check is made if the field wasn't changed" do
    end
  end

  # ----------------------------------------------------------------------------
  defmodule OnSuccess do 
    use Ecto.Schema
    embedded_schema do
      field :date_string, :string, virtual: true
      field :date, :date
      field :days_since_2000, :integer
    end
  end

  describe "on_success is evaluated later" do 
    test "in a success case" do 
      test_data =
        TestBuild.one_category(:success,
          [module_under_test: OnSuccess,
           field_transformations: [
             as_cast: [:date_string],
             date: on_success(Date.from_iso8601!(:date_string))
           ]
          ],
          ok: [params(date_string: "2001-01-01")])

      [:valid, changes: [date_string: "2001-01-01"], __custom_changeset_check: f] =
        Checks.get(test_data, :ok, :validation)

      success = %Changeset{
        changes: %{date_string: "2001-01-01",
                   date: ~D[2001-01-01]}}
      assert f.(success) == :ok


      failure = %Changeset{
        changes: %{date_string: "2001-01-01",
                   date: ~D[2001-01-02]}}
      assertion_fails(
        "Changeset field `:date` (left) does not match the value calculated from &Date.from_iso8601!/1[:date_string]",
        [left: ~D[2001-01-02], right: ~D[2001-01-01]],
        fn -> 
          f.(failure)
        end)
    end

    test "no check added when a validation failure is expected" do 
      test_data =
        TestBuild.one_category(:validation_error,
          [module_under_test: OnSuccess,
           field_transformations: [
             as_cast: [:date_string],
             date: on_success(&Date.from_iso8601!/1, applied_to: :date_string)
           ]
          ],
          error: [params(date_string: "2001-01-0")])

      actual = Checks.get(test_data, :error, :validation)
      assert [:invalid, changes: [date_string: "2001-01-0"]] = actual
    end

    test "more than one argument to checking function" do 
      test_data =
        TestBuild.one_category(:success,
          [module_under_test: OnSuccess,
           field_transformations: [
             as_cast: [:date_string],
             date: on_success(Date.from_iso8601! :date_string),
             days_since_2000:
                on_success(Date.diff(:date, ~D[2000-01-01]))
           ]
          ],
          ok: [params(date_string: "2000-01-04")])

      [:valid, changes: [date_string: "2000-01-04"],
        __custom_changeset_check: _date,
        __custom_changeset_check: days_since] =
          Checks.get(test_data, :ok, :validation)

      success = %Changeset{
        changes: %{date_string: "2000-01-04",
                   date: ~D[2000-01-04],
                   days_since_2000: 3}}
      assert days_since.(success) == :ok

      failure = %Changeset{
        changes: %{date_string: "2000-01-04",
                   date: ~D[2000-01-04],
                   days_since_2000: -3}}
        
      assertion_fails(
        "Changeset field `:days_since_2000` (left) does not match the value calculated from &Date.diff/2[:date, ~D[2000-01-01]]",
        [left: -3, right: 3],
        fn -> 
          days_since.(failure)
        end)
    end

    @tag :skip
    test "no check is made if the field wasn't changed" do
    end
  end
end
