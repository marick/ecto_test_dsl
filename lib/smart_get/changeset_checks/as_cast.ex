defmodule TransformerTestSupport.SmartGet.ChangesetChecks.AsCast do
  alias TransformerTestSupport.SmartGet
  alias SmartGet.{Example,Params}
  alias Ecto.Changeset
    
  @moduledoc """
  """

  defp insertion_changeset(example, previously, fields) do
    module = Example.module_under_test(example)
    empty = struct(module)

    Changeset.cast(empty, Params.get(example, previously: previously), fields)
  end

  def add(changeset_checks, _example, _previously, []), do: changeset_checks
  def add(changeset_checks, example, previously, fields) do
    changeset_from_cast = insertion_changeset(example, previously, fields)
    add_checks(changeset_checks, fields, changeset_from_cast)
  end


  defp add_checks(changeset_checks, all_fields, from_cast) do
    named_in_changes? = &(&1 in Map.    keys(from_cast.changes))
    named_in_errors?  = &(&1 in Keyword.keys(from_cast.errors))

    fields = %{
      changes:    Enum.filter(all_fields, named_in_changes?),
      no_changes: Enum.reject(all_fields, named_in_changes?),
      errors:     Enum.filter(all_fields, named_in_errors?)
    }

    new_checks = %{
      changes: (for f <- fields.changes, do: {f, from_cast.changes[f]}),
      no_changes: (for f <- fields.no_changes, do: f),
      errors: (for f <- fields.errors do
                {f, Keyword.get(from_cast.errors, f) |> elem(0)}
              end)
    }
    order_of_additions = [:changes, :no_changes, :errors]

    # We don't mess with user's `changeset` checks. We just add
    # new keywords.
    Enum.reduce(order_of_additions, changeset_checks, fn check_type, acc ->
      additions = new_checks[check_type]
      case additions do 
        [] -> acc
        _ -> acc ++ [{check_type, additions}]
      end
    end)
  end

end
