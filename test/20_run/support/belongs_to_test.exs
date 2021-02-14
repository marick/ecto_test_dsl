defmodule Run.Support.BelongsToTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  use T.Parse.Exports
  import FlowAssertions.Ecto.SchemaA

  defmodule Schema do
    use Ecto.Schema
    import Ecto.Changeset
    
    schema "irrelevant" do
      field :name, :string
      belongs_to :peer, __MODULE__
    end

    def changeset(struct, attrs) do
      struct
      |> cast(attrs, [:name, :peer_id])
    end
  end

  defmodule Examples do 
    use Template.PhoenixGranular.Insert

    def create_test_data do
      started(module_under_test: Schema) |>
      SimpleFakeRepo.with_ids(name: %{"no peer" => 111, "has peer" => 222}) |> 

      workflow(                                 :success,
        no_peer: [params(name: "no peer")],
        has_peer: [
          params(name: "has peer", peer_id: id_of(:no_peer)),
          changeset(changes: [peer_id: id_of(:no_peer)])
        ])
    end
  end

  test "Inserting a value that `belongs_to` a previous value gets its `id`" do
    Examples.Tester.inserted(:has_peer)
    |> assert_fields(name: "has peer",
                     id: 222,
                     peer_id: 111)
    |> refute_assoc_loaded(:peer)
  end

end
