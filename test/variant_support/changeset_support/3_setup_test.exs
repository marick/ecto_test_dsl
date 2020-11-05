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
  end

  defmodule Examples do
    use EctoClassic

    def named(name),
      do: %Schema{name: name, id: "#{name}_id"}

    def fake_insert(changeset),
      do: {:ok, named(changeset.changes.name)}

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
        dependent2: [params(name: "dependent2"), setup(insert: [:source, :source2])]
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
      assert run(:dependent) == %{source: Examples.named("source")}
    end
  end
end
