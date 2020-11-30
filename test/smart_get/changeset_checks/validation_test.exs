defmodule SmartGet.ChangesetChecks.ValidationTest do
  alias TransformerTestSupport, as: T
  use T.Case
  alias T.SmartGet.ChangesetChecks, as: Checks
  import T.Build
  alias T.RunningExample
  alias Ecto.Changeset
  alias Template.Dynamic
  import FlowAssertions.Define.Defchain

  defmodule Examples, do: use Template.EctoClassic
  
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
    test "starting with no existing checks" do
      [            as_cast: [:date],
       params:               [date:   "2001-01-01"]
      ] |> expect_changeset_checks(
        [        :valid,
                 changes:    [date: ~D[2001-01-01]]])
    end

    test "starting with existing checks" do
      [              as_cast: [:date],
       params:                 [date: "2001-01-01"],
       checks: [      changes: [name: "Bossie"]]       # <<<
      ] |> expect_changeset_checks(
        [          :valid,
                   changes:    [name: "Bossie"],
                   changes:    [date: ~D[2001-01-01]]])
    end

    test "it is OK for a parameter to be missing" do
      [              as_cast: [:other],               # <<<
       params:                 [date: "2001-01-01"],  # `other` not in params
       checks: [      changes: [name: "Bossie"]]
      ] |> expect_changeset_checks(
        [          :valid,
                   changes:    [name: "Bossie"],
                   no_changes: [:other]])             # <<<<
    end

    test "If the `cast` produces an error, that appears in the expected results" do
      [workflow:                                          :validation_error,
                     as_cast:      [:date, :name],
                      params:       [date: "2001-01-0",      # <<<<
                                            name: "Bossie"]
      ] |> expect_changeset_checks([:invalid,
                      changes:             [name: "Bossie"],
                      no_changes:  [:date],                  # <<<
                      errors:       [date: "is invalid"]])   # <<<
    end

    test "a field named in the `changeset` arg overrides auto-generated ones" do
      [               as_cast: [:date],
                       params: [date:   "2001-01-01"],
          checks: [no_changes: :date]                          # <<<
      ] |> expect_changeset_checks(
        [        :valid,
                 no_changes:   :date])
    end

    test "overriding a field's changeset prevents `as_cast` calculation" do
      [               as_cast: [:date],
                       params:  [date:   "2001-01-0"],
          checks:    [changes:  [date: ~D[2001-01-01]]]        #^^^ note the error
      ] |> expect_changeset_checks(
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
      ] |> expect_changeset_checks(
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
    test "in a success case" do
      [custom_check] =
        global_transformations([
                                    as_cast: [:date_string],
          date: on_success(Date.from_iso8601!(:date_string))])
        |> and_example(              params:  [date_string: "2001-01-01"])
        |> checks_for(:valid, date_string_check("2001-01-01"), and_custom_checks(1))

      # Provide evidence the function actually does the right thing
      custom_check
      |> assert_this_changeset_passes(date_string: "2001-01-01", date: ~D[2001-01-01])

      custom_check                                                       #vvvvvvvvvv
      |> assert_this_changeset_fails( date_string: "2001-01-01", date: ~D[2221-11-22])
      |> assert_diagnostics("Changeset field `:date` (left) does not match the value calculated from &Date.from_iso8601!/1[:date_string]",
                                                                 left: ~D[2221-11-22],
                                                                right: ~D[2001-01-01])
    end

    test "no check added when a validation failure is expected" do
      global_transformations([
                                                 as_cast: [:date_string],
                       date: on_success(Date.from_iso8601!(:date_string))])
      |> and_example(workflow: :validation_error, # <<<
                                                   params: [date_string: "2001-01-0"])
                                                                               #^^^^
      |> checks_for(:invalid, date_string_check("2001-01-0"), and_custom_checks(0))
    end

    test "more than one argument to checking function" do
      [_date_check, since_check] =
        global_transformations([
          as_cast: [:date_string],
          date: on_success(Date.from_iso8601! :date_string),
          days_since_2000: on_success(Date.diff(:date, ~D[2000-01-01]))])
      |> and_example(params: [date_string: "2000-01-04"])
      |> checks_for(:valid, date_string_check("2000-01-04"), and_custom_checks(2))

      since_check
      |> assert_this_changeset_passes(date_string: "2000-01-04",
                                      date: ~D[2000-01-04],
                                      days_since_2000: 3)
      since_check
      |> assert_this_changeset_fails(date_string: "2000-01-04",
                                     date: ~D[2000-01-04],
                                     days_since_2000: -3)
      |> assert_diagnostics("Changeset field `:days_since_2000` (left) does not match the value calculated from &Date.diff/2[:date, ~D[2000-01-01]]",
           left: -3, right: 3)
    end

    @tag :skip
    test "Three different ways of expressing an `on_success`"

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

  # ------------ Helper functions ----------------------------------------------

  defp expect_changeset_checks(opts, expected) do
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

  # For on_success

  defp global_transformations(transformations) do
    Dynamic.configure(Examples, OnSuccess)
    |> field_transformations(transformations)
  end

  defp and_example(test_data, opts) do
    workflow = Keyword.get(opts, :workflow, :validation_success)
    params = Keyword.fetch!(opts, :params)

    test_data
    |> Dynamic.example_in_workflow(workflow, [params(params)])
  end

  # For clearer lines of code
  defp and_custom_checks(n), do: n
  defp date_string_check(s), do: s

  defp checks_for(example, validity, expected_date_string, expected_function_count) do
    assert [^validity, {:changes, [date_string: ^expected_date_string]} | functions] =
      Checks.get_validation_checks(example, previously: %{})

    assert expected_function_count == length(functions)

    functions
    |> Enum.map(fn {:__custom_changeset_check, f} -> f end)
  end

  defchain assert_this_changeset_passes(f, changeset_values) do
    changeset = struct(Changeset, %{changes: Enum.into(changeset_values, %{})})
    assert f.(changeset) == :ok
  end

  defp assert_this_changeset_fails(f, changeset_values) do
    changeset = struct(Changeset, %{changes: Enum.into(changeset_values, %{})})
    assert_raise(ExUnit.AssertionError, fn ->
      f.(changeset)
    end)
  end

  defchain assert_diagnostics(assertion_error, message, others) do
    assertion_error
    |> assert_fields(message: message)
    |> assert_fields(others)
  end

end
