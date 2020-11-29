defmodule SmartGet.ChangesetChecks.ValidationTest do
  alias TransformerTestSupport, as: T
  use T.Case
  alias T.SmartGet.ChangesetChecks, as: Checks
  alias T.SmartGet.Example
  import T.Build
  alias Ecto.Changeset
  alias Template.Dynamic

  defmodule Examples do 
    use Template.Trivial
  end

  # ----------------------------------------------------------------------------
  describe "dependencies on workflow" do
    test "what becomes valid and what becomes invalid" do 
      expect = fn workflow_name, expected ->
        Dynamic.example_in_workflow(Examples, workflow_name)
        |> Checks.get_validation_checks(previously: %{})
        |> assert_equal([expected])
      end

      :validation_error   |> expect.(:invalid)
      :validation_success |> expect.(  :valid)
      :constraint_error   |> expect.(  :valid)
    end
    
    test "checks are added to the beginning" do
      Dynamic.example_in_workflow(Examples, :validation_success,
        [changeset(no_changes: [:date])])
      |> Checks.get_validation_checks(previously: %{})
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
    def expect(opts, expected) do
      as_cast = Keyword.fetch!(opts, :as_cast)
      workflow = Keyword.get(opts, :workflow, :validation_success)
      params = Keyword.fetch!(opts, :params)
      previously = Keyword.get(opts, :previously, %{})

      example_opts =
        case Keyword.get(opts, :checks) do
          nil -> [params(params)]
          checks -> [params(params), changeset(checks)]
        end
            

      Dynamic.configure(Examples, AsCast)
      |> field_transformations(as_cast: as_cast)
      |> Dynamic.example_in_workflow(workflow, example_opts)
      |> Checks.get_validation_checks(previously: previously)
      |> assert_equal(expected)
    end
      
    
    test "starting with no existing checks" do
      [            as_cast: [:date],
       params:               [date:   "2001-01-01"]
      ] |> expect(
        [        :valid,
                 changes:    [date: ~D[2001-01-01]]])
    end

    test "starting with existing checks" do
      [              as_cast: [:date],
       params:                 [date: "2001-01-01"],
       checks: [      changes: [name: "Bossie"]]       # <<<
      ] |> expect(
        [          :valid,
                   changes:    [name: "Bossie"],       
                   changes:    [date: ~D[2001-01-01]]])
    end

    test "it is OK for a parameter to be missing" do
      [              as_cast: [:other],               # <<<
       params:                 [date: "2001-01-01"],  # `other` not in params
       checks: [      changes: [name: "Bossie"]]
      ] |> expect(
        [          :valid,
                   changes:    [name: "Bossie"],       
                   no_changes: [:other]])             # <<<<
    end

    test "If the `cast` produces an error, that appears in the expected results" do
      [workflow:                                          :validation_error,
                     as_cast:      [:date, :name],
                      params:       [date: "2001-01-0",      # <<<<
                                            name: "Bossie"]
      ] |> expect([:invalid,
                      changes:             [name: "Bossie"],
                      no_changes:  [:date],                  # <<<
                      errors:       [date: "is invalid"]])   # <<<
    end

    test "a field named in the `changeset` arg overrides auto-generated ones" do
      [               as_cast: [:date],
                       params: [date:   "2001-01-01"],
          checks: [no_changes: :date]                          # <<<
      ] |> expect(
        [        :valid,
                 no_changes:   :date])
    end


    test "overriding a field's changeset prevents `as_cast` calculation" do
      [               as_cast: [:date],
                       params:  [date:   "2001-01-0"],
          checks:    [changes:  [date: ~D[2001-01-01]]]        #^^^ note the error   
      ] |> expect(
        [              :valid,
                      changes:  [date: ~D[2001-01-01]]])
      # The lack of an assertion failure, gives evidence that
      # the actual `cast` value of the `date` parameter is never calculated.
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

    test "`previously` values are obeyed" do
      [ as_cast: [:species_id],
        params:  [ species_id: id_of(:prerequisite)],
        previously:              %{ {:prerequisite, __MODULE__} => %{id: 383}}
      ] |> expect(
        [:valid,
         changes:  [species_id:                                          383]])
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
    @tag :skip # current
    test "in a success case" do 
      test_data =
        TestBuild.one_workflow(:success,
          [module_under_test: OnSuccess,
           field_transformations: [
             as_cast: [:date_string],
             date: on_success(Date.from_iso8601!(:date_string))
           ]
          ],
          ok: [params(date_string: "2001-01-01")])

      [:valid, changes: [date_string: "2001-01-01"], __custom_changeset_check: f] =
        Example.get(test_data, :ok) |> Checks.get_validation_checks(previously: %{})

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

    @tag :skip # current
    test "no check added when a validation failure is expected" do 
      actual =
        TestBuild.one_workflow(:validation_error,
          [module_under_test: OnSuccess,
           field_transformations: [
             as_cast: [:date_string],
             date: on_success(&Date.from_iso8601!/1, applied_to: :date_string)
           ]
          ],
          error: [params(date_string: "2001-01-0")])
      |> Example.get(:error)
      |> Checks.get_validation_checks(previously: %{})
      assert [:invalid, changes: [date_string: "2001-01-0"]] = actual
    end

    @tag :skip # current
    test "more than one argument to checking function" do 
      test_data =
        TestBuild.one_workflow(:success,
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
        test_data
        |> Example.get(:ok)
        |> Checks.get_validation_checks(previously: %{})

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
