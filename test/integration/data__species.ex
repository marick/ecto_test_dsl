defmodule Integration.Species do

  defmodule Schema do
    use Ecto.Schema
    import Ecto.Changeset

    schema "bogus" do 
      field :name, :string
    end

    def changeset(struct, params) do
      struct
      |> cast(params, [:name])
    end
  end
end
