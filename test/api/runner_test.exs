defmodule Api.RunnerTest do
  alias TransformerTestSupport, as: T
  alias T.Build
  alias T.Runner
  alias T.Variants.EctoClassic
  alias Ecto.Changeset

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

    def fake_insert(changeset),
      do: {:ok, "fake insertion of #{changeset.changes.name}"}

    def create_test_data do 
      start(
        module_under_test: Schema,
        format: :phoenix,
        repo: :unused
      ) |>
      
      replace_steps(insert_changeset: step(&fake_insert/1, :make_changeset)) |>
      
      category(                                         :success,
        young: [params(name: "young")],
        dependent: [params(name: "dependent"), setup(insert: :young)],
        two_level: [params(name: "dependent"), setup(insert: :dependent)]
      )
    end
  end

  defmodule Tests do
    use TransformerTestSupport.Case

    test "stopping early after a step" do
      assert [make_changeset: made, repo_setup: %{}, repo_setup: %{}, example: _] = 
        Examples.Tester.example(:young) |> Runner.run_example_steps(stop_after: :make_changeset)
      
      made
      |> assert_shape(%Changeset{})
    end


    test "A starting setup-state can be passed in" do
      actual = 
        Examples.Tester.example(:dependent)
        |> Runner.run_example_steps(previously: %{young: "presupplied"})
      assert Keyword.get(actual, :repo_setup) == %{young: "presupplied"}
    end

    test "works for recursive call" do
      actual = 
        Examples.Tester.example(:two_level)
        |> Runner.run_example_steps(previously: %{young: "presupplied"})
      assert Keyword.get(actual, :repo_setup) == %{
        young: "presupplied",
        dependent: "fake insertion of dependent"
      }
    end
    
  end
end

  
