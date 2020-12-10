defmodule VariantSupport.Changeset.CheckValidationChangesetTest do
  use TransformerTestSupport.Drink.Me
  use T.Case
  import FlowAssertions.Define.Tabular
  alias T.VariantSupport.ChangesetSupport
  import T.Build
  alias T.Sketch
  alias T.RunningExample
  alias T.RunningExample.History

  def run(example, changeset) do 
    %RunningExample{example: example, history: History.trivial(step: changeset)}
    |> ChangesetSupport.check_validation_changeset(:step)
  end
  # ----------------------------------------------------------------------------
  test "handling of auto-generated valid/invalid checks" do
    a = nonflow_assertion_runners_for(&(run Sketch.success_example(), &1))
    Sketch.valid_changeset()   |> a.pass.()
    Sketch.invalid_changeset() |> a.fail.(~r/changeset is invalid/)
  end
  
  # ----------------------------------------------------------------------------
  test "handling of explicit assertions" do
    a = nonflow_assertion_runners_for(fn example_checks, changeset_changes ->
      run(
        Sketch.example(:ok, :success, changeset_for_validation_step: example_checks),
        Sketch.valid_changeset(       changes: changeset_changes))
    end)
    
    [[:no_changes], %{}        ] |> a.pass.()
    [[:no_changes], %{age: 1}, ] |> a.fail.(~r/No fields were supposed to change/)

    [[change: [age: 1]], %{age: 1} ] |> a.pass.()
    [[change: [age: 2]], %{age: 1} ] |> a.fail.(~r/Field `:age` has the wrong value/)
  end

  # ----------------------------------------------------------------------------
  defmodule Schema do
    use Ecto.Schema

    embedded_schema do
      field :age, :integer
      field :date_string, :string
      field :date, :date
    end
  end

  test "failure with field transformers" do
    a = nonflow_assertion_runners_for(fn example_params, changeset_changes ->
      example =
        Sketch.example(:ok, :success, params: example_params)
        |> Sketch.merge_metadata(
          module_under_test: Schema,
          field_transformations: [
            as_cast: [:date_string, :age],
            date: on_success(Date.from_iso8601!(:date_string))])

      run(example, Sketch.valid_changeset(changes: changeset_changes))
    end)

    message = ~r/`:date`.* does not match/


    [%{age: 1}, %{age: 1}] |> a.pass.()
    [%{age: 1}, %{age: "1"}] |> a.fail.(~r/Field `:age` has the wrong value/)

    [%{date_string: "2001-01-01"},
     %{date_string: "2001-01-01", date: ~D[2001-01-01]}] |> a.pass.()
    
    [%{date_string: "2001-01-01"},
     %{date_string: "2001-01-01", date: ~D[2002-02-20]}] |> a.fail.(message)

    [%{date_string: "2001-01-01"},
     %{date_string: "2001-01-01", date: nil}]            |> a.fail.(message)

    no_date = ~R/The changeset has all the prerequisites to calculate `:date`.*, but `:date` is not in the changeset's changes./

    [%{date_string: "2001-01-01"},
     %{date_string: "2001-01-01"}]                       |> a.fail.(no_date)

  end
end
