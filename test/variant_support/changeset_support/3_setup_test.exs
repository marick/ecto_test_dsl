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

    def make(name),
      do: {name, [params(name: to_string(name))]}
    def make(name, one_setup),
      do: {name, [params(name: to_string(name)), one_setup]}

    def create_test_data do 
      start(
        module_under_test: Schema,
        format: :phoenix
      ) |>

      replace_steps(insert_changeset: step(&fake_insert/1, :make_changeset)) |> 
      
      category(                                         :success, [
        make(:source),
        make(:source2),
        make(:dependent,  setup(insert:  :source)),
        make(:dependent2, setup(insert: [:source, :source2])),
        make(:chained,    setup(insert: :dependent)),
        make(:multiple,   setup(insert: :chained, insert: :source2))
      ])
    end
  end

  defmodule ActualTests do
    use T.Case
    
    def setup_for(example_name) do
      Examples.Tester.check_workflow(example_name)
      |> Keyword.get(:repo_setup)
    end

    def expect(actual, names) do
      expected = 
        names
        |> Enum.map(fn name -> {name, Schema.named(to_string name)} end)
        |> Map.new
      assert actual == expected
    end
    
    # ----------------------------------------------------------------------------

    test "insertions" do
      setup_for(:source)     |> expect([])  # no setup clause
      setup_for(:dependent)  |> expect([:source]) # depends on one other value
      setup_for(:dependent2) |> expect([:source, :source2])  # depends on two
      setup_for(:chained)    |> expect([:source, :dependent]) # recurses
      setup_for(:multiple)   |> expect([:chained, :dependent, :source, :source2])
    end
  end
end
