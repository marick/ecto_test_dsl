defmodule SimpleFakeRepo do
  alias Ecto.Changeset
  
  defstruct [:changeset_key, :id_map]
  
  def new(changeset_key, id_map),
    do: %__MODULE__{changeset_key: changeset_key, id_map: id_map}

  def with_ids(test_data, [{changeset_key, id_map}]) do
    test_data
    |> Map.put(:repo, new(changeset_key, id_map))
    |> Map.put(:insert_with, &insert/2)
  end
  
  defp choose_id(repo, changeset) do 
    id_map_key = changeset.changes[repo.changeset_key]
    Map.get(repo.id_map, id_map_key)
  end
  
  def insert(repo, changeset) do
    id = choose_id(repo, changeset)
    changeset
    |> Changeset.put_change(:id, id)
    |> Changeset.apply_action(:insert)
  end
end      

