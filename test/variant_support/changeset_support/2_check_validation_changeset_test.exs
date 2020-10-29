defmodule VariantSupport.Changeset.CheckValidationChangesetTest do
  alias TransformerTestSupport, as: T
  use T.Case
  import FlowAssertions.Define.Tabular
  alias T.VariantSupport.Changeset, as: ChangesetS
  alias Ecto.Changeset
  import T.Build
  # alias TransformerTestSupport.SmartGet

  def make_example(name, category, example_fields \\ []) do
    default_metadata = %{field_transformations: [], format: :phoenix}
    given_metadata = %{name: name, category_name: category}

    Enum.into(example_fields, %{})
    |> Map.put(:metadata, Map.merge(default_metadata, given_metadata))
  end

  def add_metadata(example, metadata_fields) do
    metadata_fields = Enum.into(metadata_fields, %{})
    DeepMerge.deep_merge(
      example,
      %{metadata: metadata_fields})
  end

  def make_changeset(fields \\ []) do
    fields = Enum.into(fields, %{})
    struct(Changeset, fields)
  end
    
  def valid_changeset(fields \\ []) do
    make_changeset(fields)
    |> Map.put(:valid?, true)
  end

  def invalid_changeset(fields \\ []) do
    make_changeset(fields)
    |> Map.put(:valid?, false)
  end

  def trivial_example, do:  make_example(:ok, :success)

  # ----------------------------------------------------------------------------
  def run(example, changeset),
    do: ChangesetS.check_validation_changeset(changeset, example)

  test "handling of auto-generated valid/invalid checks" do
    a = nonflow_assertion_runners_for(&(run trivial_example(), &1))
    valid_changeset()   |> a.pass.()
    invalid_changeset() |> a.fail.(~r/changeset is invalid/)
  end
  
  test "handling of explicit assertions" do
    a = nonflow_assertion_runners_for(fn example_checks, changeset_changes ->
      run(
        make_example(:ok, :success, changeset: example_checks),
        valid_changeset(              changes: changeset_changes))
    end)
    
    [[:no_changes], %{}        ] |> a.pass.()
    [[:no_changes], %{age: 1}, ] |> a.fail.(~r/No fields were supposed to change/)

    [[change: [age: 1]], %{age: 1} ] |> a.pass.()
    [[change: [age: 2]], %{age: 1} ] |> a.fail.(~r/Field `:age` has the wrong value/)
  end


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
        make_example(:ok, :success, params: example_params)
        |> add_metadata(
          module_under_test: Schema,
          field_transformations: [
            as_cast: [:date_string, :age],
            date: on_success(Date.from_iso8601!(:date_string))])
      
      run(example, valid_changeset(changes: changeset_changes))
    end)


    [%{age: 1}, %{age: 1}] |> a.pass.()
    [%{age: 1}, %{age: "1"}] |> a.fail.(~r/Field `:age` has the wrong value/)

    [%{date_string: "2001-01-01"},
     %{date_string: "2001-01-01", date: ~D[2001-01-01]}] |> a.pass.()
    
    [%{date_string: "2001-01-01"},
     %{date_string: "2001-01-01", date: ~D[2002-02-20]}] |> a.fail.(~r/`:date`.* does not match/)

    [%{date_string: "2001-01-01"},
     %{date_string: "2001-01-01", date: nil}] |> a.fail.(~r/`:date`.* does not match/)

    [%{date_string: "2001-01-01"},
     %{date_string: "2001-01-01"}] |> a.fail.(~r/`:date`.* does not match/)

  end
end
