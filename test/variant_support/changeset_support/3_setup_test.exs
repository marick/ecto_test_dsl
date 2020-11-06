defmodule VariantSupport.Changeset.SetupTest do
  alias TransformerTestSupport, as: T
  alias T.Variants.EctoClassic

  defmodule Schema do
    use Ecto.Schema
    import Ecto.Changeset

    embedded_schema do
      field :name, :string
    end

    def changeset(struct, params) do
      struct
      |> cast(params, [:name])
      |> validate_required([:name])
    end

    def named(name),
      do: %Schema{name: name, id: "#{name}_id"}
  end

  defmodule Examples do
    use EctoClassic

    def fake_insert(changeset),
      do: {:ok, Schema.named(changeset.changes.name)}

    def create_test_data do 
      start(
        module_under_test: Schema,
        format: :phoenix
      ) |>

      replace_steps(insert_changeset: step(&fake_insert/1, :make_changeset)) |> 
      
      category(                                         :success,
        source: [params(name: "source")],
        source2: [params(name: "source2")],
        dependent: [params(name: "dependent"), setup(insert: :source)],
        dependent2: [params(name: "dependent2"), setup(insert: [:source, :source2])],

        chained: [params(name: "chained"), setup(insert: :dependent)],
        multiple: [params(name: "multiple"),
                     setup(insert: :chained,
                           insert: :source2)]
      )
    end
  end

  defmodule ActualTests do
    use T.Case
#    alias T.VariantSupport.ChangesetSupport
#    alias T.SmartGet.Example
    
    def run(example_name) do
      Examples.Tester.check_workflow(example_name)
      |> Keyword.get(:repo_setup)
    end
    
    # ----------------------------------------------------------------------------

    test "if no specific setup, none done" do
      assert run(:source) == %{}
    end
    
    test "single stereotyped insertion" do
      assert run(:dependent) == %{source: Schema.named("source")}
    end

    test "double insertion" do
      actual = run(:dependent2)
      expected = %{
        source: Schema.named("source"),
        source2: Schema.named("source2")}
      assert actual == expected
    end
    
    test "chained insertion" do
      actual = run(:chained)
      expected = %{
        source: Schema.named("source"),
        dependent: Schema.named("dependent")}
      assert actual == expected
    end

    test "multiple" do
      actual = run(:multiple)
      expected = %{
        chained: Schema.named("chained"),
        dependent: Schema.named("dependent"),
        source: Schema.named("source"),
        source2: Schema.named("source2")}
      assert actual == expected
    end
  end
end
