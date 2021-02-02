defmodule EctoTestDSL.Run.Support.ExampleTest do
  use EctoTestDSL.Drink.Me
  
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
    use T.Variants.PhoenixGranular.Insert

    def fake_insert(_repo, changeset),
      do: {:ok, "created `#{changeset.changes.name}`"}

    def create_test_data do 
      start(
        module_under_test: Schema,
        repo: :unused,
        insert_with: &fake_insert/2
      ) |>
      
      workflow(                                         :success,
        young: [params(name: "young")],
        dependent: [params(name: "dependent"), previously(insert: :young)],
        two_level: [params(name: "dependent"), previously(insert: :dependent)]
      )
    end
  end

  defmodule Tests do
    use EctoTestDSL.Case
    alias EctoTestDSL.Run

    test "`example` can stop early in a workflow" do
      assert [
        changeset_from_params: made, params: %{"name" => "young"},
          repo_setup: %{}, repo_setup: %{}, example: _] = 
        Examples.Tester.example(:young) |> Run.example(stop_after: :changeset_from_params)
      
      made
      |> assert_shape(%Changeset{})
      |> assert_change(name: "young")
    end

    @presupplied "presupplied, not created"

    test "a neighborhood (from a nested `repo_setup`) can be passed in" do
      expect = fn example_name, expected ->
        actual =  
          Examples.Tester.example(example_name)
          |> Run.example(repo_setup:
                %{een(young: Examples) => "presupplied, not created"})
        assert Keyword.get(actual, :repo_setup) == expected
      end

      :dependent |> expect.(%{een(young: Examples) => @presupplied})
      # There is a recursive call
      :two_level |> expect.(%{
            een(young: Examples) => @presupplied,
            een(dependent: Examples) => "created `dependent`"})
    end
  end
end

  
