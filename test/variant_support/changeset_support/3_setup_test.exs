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

    def fake_insert(changeset) do
      name = changeset.changes.name

      case name do
        "ok" -> {:ok, %Schema{name: name, id: 1}}
        "dependent" -> {:ok, %Schema{name: name, id: 2}}
      end
    end

    def create_test_data do 
      start(
        module_under_test: Schema,
        format: :phoenix
      ) |>

      replace_steps(insert_changeset: step(&fake_insert/1, :make_changeset)) |> 
      
      category(                                         :success,
        ok: [params(name: "ok")],
        dependent: [params(name: "dependent"), setup(insert: :ok)]
      )
    end
  end

  defmodule ActualTests do
    use T.Case
    alias T.VariantSupport.ChangesetSupport
    alias T.SmartGet.Example
    
    def run(example),
      do: ChangesetSupport.setup(example)
    
    # ----------------------------------------------------------------------------
    test "handling of ok/error" do
      Examples.Tester.check_workflow(:dependent)
      |> Keyword.get(:repo_setup)
      |> assert_equal(%{a: 1})
      
      # run(example, {:ok, :ignored}) # no assertion failure
      
      # changeset =
      #   %Changeset{valid?: false} |>
      #   Changeset.add_error(:date, "error message")
      
      # assertion_fails(~r/Example `:name`: Unexpected insertion failure/,
      #   [left: [date: {"error message", []}]],
      #   fn ->
      #     run(example, {:error, changeset})
      #   end)
    end
  end
end
