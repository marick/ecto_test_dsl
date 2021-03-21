defmodule EctoTestDSL.Run.Support.NeighborhoodCreationTest do
  use EctoTestDSL.Drink.Me
  
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
    use T.Variants.PhoenixGranular.Insert

    def fake_insert(_repo, changeset),
      do: {:ok, %Schema{name: "created `#{changeset.changes.name}`"}}

    def create_test_data do 
      start(
        api_module: Schema,
        repo: :unused,
        insert_with: &fake_insert/2
      )
      
      workflow(                                         :success,
        young: [params(name: "young")],
        dependent: [params(name: "dependent"), previously(insert: :young)],
        two_level: [params(name: "two_level"), previously(insert: :dependent)]
      )
    end
  end

  defmodule Tests do
    use EctoTestDSL.Case
    alias EctoTestDSL.Run

    defp mk_getter(neighborhood, example_name) do
      fn subtype ->
        Neighborhood.fetch!(neighborhood, een([{example_name, Examples}]), subtype)
      end
    end

    test "a neighborhood (from a nested `repo_setup`) can be passed in" do
      presupplied = Neighborhood.Value.inserted("presupplied, not created")

      neighborhood =
        Examples.Tester.example(:two_level)
        |> Run.example(repo_setup: %{een(young: Examples) => presupplied})
        |> Keyword.get(:repo_setup)

      assert Map.get(neighborhood, een(young: Examples)) == presupplied

      dependent = mk_getter(neighborhood, :dependent)
      dependent.(:params)    |> assert_equal(%{name: "dependent"})
      dependent.(:inserted)  |> assert_equal(%Schema{name: "created `dependent`"})
      dependent.(:changeset) |> assert_change(name: "dependent")
    end

    test "neightborhood gets created even when only params are created" do
      neighborhood =
        Examples.Tester.example(:two_level)
        |> Run.example(stop_after: :changeset_from_params)
        |> Keyword.get(:repo_setup)

      young = mk_getter(neighborhood, :young)
      young.(:params)    |> assert_equal(%{name: "young"})
      young.(:inserted)  |> assert_equal(%Schema{name: "created `young`"})
      young.(:changeset) |> assert_change(name: "young")
      
      dependent = mk_getter(neighborhood, :dependent)
      dependent.(:params)    |> assert_equal(%{name: "dependent"})
      dependent.(:inserted)  |> assert_equal(%Schema{name: "created `dependent`"})
      dependent.(:changeset) |> assert_change(name: "dependent")
    end
  end
end

  
