defmodule EctoTestDSL.Nouns.AsCast do
  use EctoTestDSL.Drink.Me
  use T.Drink.Assertively
  use T.Drink.AndRun
  alias Ecto.Changeset
  alias T.Nouns.AsCast

  @moduledoc """
  A reference to a schema field.
  """

  defstruct [:field_names]

  def new(field_names), do: ~M{%AsCast field_names}
  def nothing(), do: new([])

  def merge(%AsCast{field_names: first}, %AsCast{field_names: second}),
    do: new(first ++ second)

  def subtract(~M{%AsCast field_names}, names),
    do: field_names |> EnumX.difference(names) |> new

  def changeset_checks(%AsCast{field_names: []}, _schema, _params), do: []
  def changeset_checks(~M{%AsCast field_names}, schema, params) do
    changeset = cast_results(schema, field_names, params)

    mentioned = fn changeset_part ->
      KeyVal.filter_by_key(changeset_part, &(&1 in field_names))
    end

    changes =
      mentioned.(changeset.changes)
    unchanged =
      EnumX.difference(field_names, Keyword.keys(changes))
    errors =
      mentioned.(changeset.errors)
      |> KeywordX.functor_map(&(elem &1, 0))

    [changes: changes, no_changes: unchanged, errors: errors]
    |> KeyVal.reject_by_value(&Enum.empty?/1)
  end


  defp cast_results(schema, field_names, params) do
    struct(schema)
    |> Changeset.cast(params, field_names)
  end

  # ----------------------------------------------------------------------------

  def assertions(%AsCast{} = data, schema, params) do
    data
    |> changeset_checks(schema, params)
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
