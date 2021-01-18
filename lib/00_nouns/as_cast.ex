defmodule TransformerTestSupport.Nouns.AsCast do
  use TransformerTestSupport.Drink.Me
  use T.Drink.AssertionJuice
  use T.Drink.AndRun
  alias Ecto.Changeset
  alias T.Nouns.AsCast

  @moduledoc """
  A reference to a schema field.
  """

  defstruct [:module, :field_names]

  def new(module, field_names) do
    %AsCast{module: module, field_names: field_names}
  end

  def nothing() do
    %AsCast{module: :nothing, field_names: []}
  end

  def merge(%AsCast{} = first, %AsCast{} = second) do
    new(second.module, first.field_names ++ second.field_names)
  end

  def subtract(%AsCast{} = first, names)do
    new_names = EnumX.difference(first.field_names, names)
    new(first.module, new_names)
  end


  def changeset_checks(%AsCast{field_names: []}, _params), do: []
  def changeset_checks(%AsCast{} = data, params) do
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

    [changes: changes, no_changes: unchanged, errors: errors]
    |> KeywordX.reject_by_value(&Enum.empty?/1)
  end


  defp cast_results(data, params) do
    struct(data.module)
    |> Changeset.cast(params, data.field_names)
  end

  # ----------------------------------------------------------------------------

  def assertions(%AsCast{} = data, params) do
    data
    |> changeset_checks(params)
    |> ChangesetAssertions.from
    |> Enum.map(&(friendlier_location &1, data.field_names))
  end

  defp friendlier_location(f, field_names) do 
    fn changeset ->
      adjust_assertion_error(fn -> 
        f.(changeset)
      end,
        expr: fn expr -> [[as_cast: field_names], "expanded to", expr] end)
    end
  end
end
