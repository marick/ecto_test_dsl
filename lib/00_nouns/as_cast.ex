defmodule TransformerTestSupport.Nouns.AsCast do
  use TransformerTestSupport.Drink.Me
#  import FlowAssertions.Define.BodyParts
  #  alias T.Messages
  alias Ecto.Changeset

  @moduledoc """
  A reference to a schema field.
  """

  defstruct [:module, :field_names]

  def new(module, field_names) do
    %__MODULE__{module: module, field_names: field_names}
  end

  

  def changeset_checks(%__MODULE__{} = data, params) do
    changeset = cast_results(data, params)

    mentioned = fn changeset_part ->
      KeywordX.filter_by_key(changeset_part, &(&1 in data.field_names))
    end

    changes =
      mentioned.(changeset.changes)
    unchanged =
      EnumX.difference(data.field_names, Keyword.keys(changes))
    errors =
      mentioned.(changeset.errors)
      |> KeywordX.map_over_values(&(elem &1, 0))

    [changes: changes,
     no_changes: unchanged,
     errors: errors]
  end


  defp cast_results(data, params) do
    struct(data.module)
    |> Changeset.cast(params, data.field_names)
  end

    
  
end