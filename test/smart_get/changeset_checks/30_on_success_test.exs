defmodule SmartGet.ChangesetChecks.OnSuccessTest do
  use TransformerTestSupport.Case
  alias T.SmartGet.ChangesetChecks, as: Checks
  alias T.SmartGet.Example
  use T.Parse.All
  alias T.RunningExample

  
  defmodule OnSuccess do
    use Ecto.Schema
    embedded_schema do
      field :date_string, :string, virtual: true
      field :date, :date
      field :days_since_2000, :integer
    end
  end

  defmodule Examples do 
    use Template.EctoClassic.Insert

    def create_test_data do
      started(module_under_test: OnSuccess) |> 

      field_transformations(
        date: on_success(           Date.from_iso8601!(:date_string)),
        days_since_2000: on_success(Date.diff(         :date, ~D[2000-01-01]))) |> 

      workflow(                                 :success,
        example: [params(date_string: "2001-01-01")]
      ) |>

      workflow(                                 :validation_error,
        error: [params(date_string: "1")]
      )
    end
  end

  describe "on_success checks are functions evaluated against a changeset" do
    setup do
      assert [:valid,
              {:__custom_changeset_check, date_check}, 
              {:__custom_changeset_check, days_since_check}] = 
        Example.get(Examples, :example)
        |> Checks.get_validation_checks(previously: %{})

      [checks: %{date: date_check, days_since: days_since_check}]
    end
    
    test "a case where the changeset is as expected", %{checks: checks} do
      changeset = valid_with_changes(
        date_string: "2000-01-01", date: ~D[2000-01-01], days_since_2000: 0)
      assert checks.date.(changeset) == :ok
      assert checks.days_since.(changeset) == :ok
    end

    test "handling a case where the changeset was calculated wrongly",
      %{checks: checks}  do
      changeset = valid_with_changes(                                 ### V
        date_string: "2000-01-01", date: ~D[2000-01-01], days_since_2000: 1)

      assert checks.date.(changeset) == :ok

      msg = "Changeset field `:days_since_2000` (left) does not match " <>
            "the value calculated from &Date.diff/2[:date, ~D[2000-01-01]]"
      assertion_fails(msg,
        [left: 1, right: 0],
        fn -> checks.days_since.(changeset) end)
    end

    test "what happens when the changeset value blows up the transforming function",
      %{checks: checks} do
      changeset = valid_with_changes(### VVVVVVVVVVVVV
        date_string: "2000-01-01", date: "oh so wrong", days_since_2000: 0)

      msg = ~S|FunctionClauseError was raised when field transformer | <>
            ~S|&Date.diff/2[:date, ~D[2000-01-01]] was applied to | <>
            ~S|["oh so wrong", ~D[2000-01-01]]|
      assertion_fails(msg, fn -> checks.days_since.(changeset) end)
    end

    test "transformations are only applied to changed fields", %{checks: checks}  do
      changeset = valid_with_changes(date_string: "2000-01-01")
      assert checks.days_since.(changeset) == :ok
                   #^^^^^^^^^^
      # For behavior of `date` check, see below.
    end

    test "a special error when a supposed-to-be-changed field is not present", %{checks: checks}  do
      changeset = valid_with_changes(date_string: "2000-01-01")

      msg = "The changeset has all the prerequisites to calculate `:date` " <>
            "(using &Date.from_iso8601!/1[:date_string]), but `:date` " <>
            "is not in the changeset's changes"
      assertion_fails(msg, fn -> checks.date.(changeset) end)
    end
  end

  test "no check added when a validation failure is expected" do
    assert [:invalid] =
      Example.get(Examples, :error)
      |> Checks.get_validation_checks(previously: %{})
  end

  # ------------ Helper functions ----------------------------------------------

  defp valid_with_changes(opts),
    do: ChangesetX.valid_changeset(changes: Enum.into(opts, %{}))
end
