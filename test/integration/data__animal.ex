defmodule Integration.Animal do
  defmodule Schema do 
    use Ecto.Schema
    import Ecto.Changeset
    alias Integration.Species.Schema, as: Species
    
    schema "bogus" do
      field :age, :integer
      field :date_string, :string, virtual: true
      field :date, :date
      field :days_since_2000, :integer
      belongs_to :species, Species
      field :optional_comment, :string
      field :defaulted_comment, :string, default: "no comment"
    end

    def fields_to_cast, do: [:age, :date_string, :species_id,
                             :optional_comment, :defaulted_comment]
    def required_fields, do: [:date_string, :age, :species_id]

    def changeset(struct, params) do
      struct
      |> cast(params, fields_to_cast())
      |> validate_required(required_fields())
      |> calculate_date
      |> count_the_days
    end

    def calculate_date(changeset) do
      with(
        date_string <- Map.get(changeset.changes, :date_string),
        {:ok, date} <- Date.from_iso8601(date_string)
      ) do
        put_change(changeset, :date, date)
      else
        nil ->
          changeset
        {:error, _} ->
          add_error(changeset, :date_string, "has an invalid format")
      end     
    end

    def count_the_days(%{valid?: false} = changeset), do: changeset
    def count_the_days(changeset) do
      days = Date.diff(changeset.changes.date, ~D[2000-01-01])
      put_change(changeset, :days_since_2000, days)
    end
  end

  
end
