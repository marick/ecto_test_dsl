defmodule SmartGet.ChangesetChecks.ValidationTest do
  alias TransformerTestSupport, as: T
  use T.Case
  alias T.SmartGet.ChangesetChecks, as: Checks
  alias T.SmartGet.Example
  import T.Build
  alias T.RunningExample
  alias T.Sketch

  
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
    test "in a success case" do
      [date_check, days_since_check] = checks(:example)
      changeset =
        Sketch.valid_changeset(changes: %{date_string: "2000-01-01",
                                          date:        ~D[2000-01-01],
                                          days_since_2000: 0})
      assert date_check.(changeset) == :ok
      assert days_since_check.(changeset) == :ok
    end

    test "handling a case where the changeset was calculated wrongly" do
      [date_check, days_since_check] = checks(:example)
      changeset =
        Sketch.valid_changeset(changes: %{date_string: "2000-01-01",
                                          date:        ~D[2000-01-01],
                                          days_since_2000: 1})

      assert date_check.(changeset) == :ok
      assertion_fails("Changeset field `:days_since_2000` (left) does not match the value calculated from &Date.diff/2[:date, ~D[2000-01-01]]",
        [left: 1, right: 0],
        fn -> 
          days_since_check.(changeset)
        end)
    end

    test "what happens when the changeset value blows up the transforming function" do
      [_date_check, days_since_check] = checks(:example)
      changeset =
        Sketch.valid_changeset(changes: %{date_string: "2000-01-01",
                                          date:        "oh so wrong",
                                          days_since_2000: 0})

      assertion_fails(~S|FunctionClauseError was raised when field transformer &Date.diff/2[:date, ~D[2000-01-01]] was applied to ["oh so wrong", ~D[2000-01-01]]|,
        fn -> 
          days_since_check.(changeset)
        end)
    end

    test "transformations are only applied to changed fields" do
      [_date_check, days_since_check] = checks(:example)
      changeset =
        Sketch.valid_changeset(changes: %{date_string: "2000-01-01"})
      
      assert days_since_check.(changeset) == :ok
    end

    test "a special error when a supposed-to-be-changed field is not present" do
      [date_check, _days_since_check] = checks(:example)
      changeset =
        Sketch.valid_changeset(changes: %{date_string: "2000-01-01"})

      assertion_fails("The changeset has all the prerequisites to calculate `:date` (using &Date.from_iso8601!/1[:date_string]), but `:date` is not in the changeset's changes",
        fn -> 
          date_check.(changeset)
        end)
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


    # @tag :skip
    # test "Three different ways of expressing an `on_success`"

  end

  # ------------ Helper functions ----------------------------------------------


  defp checks(example_name) do
    example = Example.get(Examples, example_name)
    
    assert [:valid | functions] =
      Checks.get_validation_checks(example, previously: %{})

    functions
    |> Enum.map(fn {:__custom_changeset_check, f} -> f end)
  end


end
