defmodule EctoTestDSL.Nouns.FieldCalculator do
  use EctoTestDSL.Drink.Me
  use T.Drink.AssertionJuice
  use T.Drink.AndRun

  @moduledoc """
  A description of how a field's value can be calculated in terms of
  other fields (and constants).
  """

  defstruct [:calculation, :args, :from]

  def new(calculation, args, from \\ "unknown"),
    do: %__MODULE__{calculation: calculation, args: args, from: from}

  def merge(kws1, kws2) do
    on_duplicate_key = fn field, val1, val2 ->
      elaborate_assert(val1 == val2, 
        merge_error(field),
        left: val1, right: val2)
      val1
    end
    
    Keyword.merge(kws1, kws2, on_duplicate_key)
  end

  def merge_error(field),
    do: "You gave field `#{inspect field}` two different values"

  def subtract(kws, names) do
    KeywordX.delete(kws, names)
  end

  def assertions(named_calculators, changeset) when is_list(named_calculators) do
    valid_prerequisites = valid_prerequisites(changeset)

    for {name, calculator} <- named_calculators do
      case relevant?(calculator, valid_prerequisites) do
        true ->
          args = translate_args(calculator.args, changeset)
          try do
            expected = apply(calculator.calculation, args)
            check_style_assertion({:change, [{name, expected}]}, calculator.from)
          rescue ex ->
            exception_style_assertion(ex, calculator.from, args, name)
          end
        false ->
          check_style_assertion({:no_changes, name}, calculator.from)
      end
    end
  end

  defp check_style_assertion(check, from) do 
    raw_assertion = ChangesetAssertions.from(check)
    fn changeset ->
      adjust_assertion_error(fn ->
        raw_assertion.(changeset)
      end,
        expr: from)
    end
  end

  defp exception_style_assertion(ex, from, arglist, name) do 
    line1 =
      "Exception raised while calculating value for `#{inspect name}`\n  "
    line2 =
      case Map.get(ex, :message) do
        nil ->
          inspect(ex)
        message ->
          message
      end
    fn _changeset -> 
      elaborate_flunk(line1 <> line2,
        expr: from, 
        left: ["Here are the actual arguments used": arglist])
    end
  end

  def valid_prerequisites(changeset) do
    Map.keys(changeset.changes)
    |> EnumX.difference(Keyword.keys(changeset.errors))
    |> MapSet.new
  end

  def relevant?(calculator, valid_prerequisites) do
    MapSet.subset?(
      calculator.args |> Enum.filter(&is_atom/1) |> MapSet.new,
      valid_prerequisites)
  end

  defp translate_args(args, changeset) do
    for a <- args, do: translate_arg(a, changeset)
  end
    
  defp translate_arg(arg,  changeset) when is_atom(arg), do: changeset.changes[arg]
  defp translate_arg(arg, _changeset),                   do:                   arg
end
