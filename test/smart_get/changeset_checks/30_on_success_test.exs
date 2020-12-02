defmodule SmartGet.ChangesetChecks.ValidationTest do
  alias TransformerTestSupport, as: T
  use T.Case
  alias T.SmartGet.ChangesetChecks, as: Checks
  alias T.SmartGet.Example
  import T.Build
  alias T.RunningExample
  alias T.Sketch
  alias Template.Dynamic

  
  defmodule OnSuccess do
    use Ecto.Schema
    embedded_schema do
      field :date_string, :string, virtual: true
      field :date, :date
      field :days_since_2000, :integer
    end
  end

  defmodule Examples do 
    use Template.EctoClassic

    def create_test_data do
      started(module_under_test: OnSuccess) |> 

      field_transformations(
        date: on_success(           Date.from_iso8601!(:date_string)),
        days_since_2000: on_success(Date.diff(         :date, ~D[2000-01-01]))) |> 

      workflow(                                 :success,
        example: [params(date_string: "2001-01-01")]
      )
    end
  end
  

  describe "on_success is evaluated later" do
    setup do
      [date_check, days_since_check] = checks(:example)
      [checks: %{date: date_check, days_since: days_since_check}]
    end
    
    defp valid_with_changes(opts),
      do: Sketch.valid_changeset(changes: Enum.into(opts, %{}))
    
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
    
    # test "no check added when a validation failure is expected" do
    #   global_transformations([
    #                                              as_cast: [:date_string],
    #                    date: on_success(Date.from_iso8601!(:date_string))])
    #   |> and_example(workflow: :validation_error, # <<<
    #                                                params: [date_string: "2001-01-0"])
    #                                                                            #^^^^
    #   |> checks_for(:invalid, date_string_check("2001-01-0"), and_custom_checks(0))
    # end



  # ------------ Helper functions ----------------------------------------------


  defp checks(example_name) do
    example = Example.get(Examples, example_name)
    
    assert [:valid | functions] =
      Checks.get_validation_checks(example, previously: %{})

    functions
    |> Enum.map(fn {:__custom_changeset_check, f} -> f end)
  end


end
