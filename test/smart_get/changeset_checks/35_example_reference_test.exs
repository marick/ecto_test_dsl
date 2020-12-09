defmodule SmartGet.ChangesetChecks.ExampleReferenceTest do
  alias TransformerTestSupport, as: T
  use T.Case
  import T.Build
  alias T.RunningExample

  defmodule Schema do
    use Ecto.Schema
    import Ecto.Changeset
    
    schema "irrelevant" do
      field :name, :string       # This is used as the primary key.
      belongs_to :peer, __MODULE__
    end

    def changeset(struct, attrs) do
      struct
      |> cast(attrs, [:name, :peer_id])
    end
  end

  defmodule Examples do 
    use Template.EctoClassic.Insert
    alias Ecto.Changeset

    def insert(_repo, changeset) do
      id = Map.get(%{"no peer" => 111, "has peer" => 222}, changeset.changes.name)
      changeset
      |> Changeset.put_change(:id, id)
      |> Changeset.apply_action(:insert)
    end

    def create_test_data do
      started(
        module_under_test: Schema,
        insert_with: &insert/2) |> 

      workflow(                                 :success,
        no_peer: [params(name: "no peer")],
        has_peer: [
          params(name: "has peer", peer_id: id_of(:no_peer)),
          changeset(changes: [peer_id: id_of(:no_peer)])
        ])
    end
  end

  @tag :skip
  test "foo" do
    IO.inspect Examples.Tester.inserted(:has_peer)
  end

end
