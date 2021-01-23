defmodule TransformerTestSupport.Run.RunningExampleTest do
  use TransformerTestSupport.Drink.Me
  
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
    use T.Variants.PhoenixClassic.Insert

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
    use TransformerTestSupport.Case
    alias TransformerTestSupport.Run

    test "stopping early after a step" do
      assert [
        changeset_from_params: made, params: %{"name" => "young"},
          previously: %{}, previously: %{}, example: _] = 
        Examples.Tester.example(:young) |> Run.example(stop_after: :changeset_from_params)
      
      made
      |> assert_shape(%Changeset{})
      |> assert_change(name: "young")
    end

    @presupplied "presupplied, not created"

    test "A starting previously-state can be passed in" do
      expect = fn example_name, expected ->
        actual =  
          Examples.Tester.example(example_name)
          |> Run.example(previously:
                %{een(young: Examples) => "presupplied, not created"})
        assert Keyword.get(actual, :previously) == expected
      end

      :dependent |> expect.(%{een(young: Examples) => @presupplied})
      # There is a recursive call
      :two_level |> expect.(%{
            een(young: Examples) => @presupplied,
            een(dependent: Examples) => "created `dependent`"})
    end
  end
end

  
