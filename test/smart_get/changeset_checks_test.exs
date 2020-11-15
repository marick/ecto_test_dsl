defmodule SmartGet.ChangesetChecksTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.SmartGet.ChangesetChecks, as: Checks
  alias TransformerTestSupport.SmartGet.Example
  import TransformerTestSupport.Build
  alias Ecto.Changeset

  # ----------------------------------------------------------------------------
  describe "dependencies on category" do
    test "a list" do 
      expect = fn category_name, expected ->
        TestBuild.one_category(category_name, [], example: [])
        |> Checks.get_validation_checks(:example)
        |> assert_equal([expected])
      end

      :validation_error   |> expect.(:invalid)
      :validation_success |> expect.(  :valid)
      :constraint_error   |> expect.(  :valid)
    end
    
    test "checks are added to the beginning" do
      TestBuild.one_category(:validation_success,
        [],
        example: [changeset(no_changes: [:date])])
      |> Checks.get_validation_checks(:example)
      |> assert_equal([:valid, {:no_changes, [:date]}])
    end
  end

  # ----------------------------------------------------------------------------
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

  describe "adding an automatic as_cast test" do

    defp as_cast_data(fields, example_descriptions,
      category_opts \\ [category: :validation_success]) do

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
      |> Checks.get_validation_checks(previously: %{})
    end

    test "starting with no existing checks" do
      run_example([:date], [params(         date:   "2001-01-01")])
      |> assert_equal([:valid, changes:    [date: ~D[2001-01-01]]])
    end

    test "starting with existing checks" do
      run_example([:date], [params(date: "2001-01-01"),
                            changeset(changes: [name: "Bossie"])]) # existing
      |> assert_equal([:valid,
                      changes: [name: "Bossie"],
                      changes: [date: ~D[2001-01-01]]])
    end

    test "it is OK for a parameter to be missing" do
      run_example([:other], [params(date: "2001-01-01"),
                             changeset(changes: [name: "Bossie"])])
      |> assert_equal([:valid,
                      changes: [name: "Bossie"],
                      no_changes: [:other]])
    end

    test "validation errors appear in result" do
      run_example([:date, :name], [params(date: "2001-01-0", name: "Bossie")],
                  category: :validation_error)
      |> assert_equal([:invalid,
                      changes: [name: "Bossie"],
                      no_changes: [:date],             ## <<<
                      errors: [date: "is invalid"]])   ## <<<
    end

    test "a field named in the `changeset` arg overrides auto-generated ones" do 
      run_example([:date], [params(date: "2001-01-01"),
                            changeset(no_changes: :date)]) # Note date mentioned.
      |> assert_equal([:valid, no_changes: :date])
    end


    test "overriding a field's changeset prevents `as_cast` calculation" do
      run_example([:date], [params(date: "2001-01-0"),
                                         # ^^^^^^^^ note this is in error.
                            changeset(changes: [date: ~D[2001-01-01]])])
      |> assert_equal([:valid,        changes: [date: ~D[2001-01-01]]])
      # The actual `cast` value of the `date` parameter is never calculated.
    end
    
    @tag :skip
    test "no check is made if the field wasn't changed" do
      # This would be relevant to update
      #    The data part of the changeset contains a bogus value.
      #    The params contains the same bogus value.
      #    This does not cause a changeset check, just as it would
      #    not cause a changeset value because those only apply to
      #    
    end

    test "`setup` values are obeyed" do
      as_cast_data([:species_id],
        example: [params(species_id: id_of(:prerequisite))])
      |> Example.get(:example)
      |> Checks.get_validation_checks(
                    previously: %{ {:prerequisite, __MODULE__} => %{id: 383}})
      |> assert_equal([:valid,        changes: [species_id: 383]])
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
        Checks.get_validation_checks(test_data, :ok)

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

      actual = Checks.get_validation_checks(test_data, :error)
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
        Checks.get_validation_checks(test_data, :ok)

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
      # This would be relevant to update
      #    The data part of the changeset contains a bogus value.
      #    The params contains the same bogus value.
      #    This does not cause a changeset check, just as it would
      #    not cause a changeset value because those only apply to
      #    
    end
  end
end
