defmodule EctoTestDSL.Run.RunningExampleTest do
  use EctoTestDSL.Drink.Me
  
#  alias Ecto.Changeset

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

    @tag :skip
    test "different entry points in Example.Tester"
  end
end

  
