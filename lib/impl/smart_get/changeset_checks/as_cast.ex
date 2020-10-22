defmodule TransformerTestSupport.Impl.SmartGet.ChangesetChecks.AsCast do
  alias TransformerTestSupport.Impl.SmartGet
  alias SmartGet.Example
  alias SmartGet.ChangesetChecks, as: Checks
  alias Ecto.Changeset
    
  @moduledoc """
  """

  

  defp insertion_changeset(example, fields) do
    struct(example.metadata.module_under_test)
    |> Changeset.cast(Example.params(example), fields)
  end

  def add(changeset_checks, example, user_mentioned) do
    case Keyword.get_values(example.metadata.field_transformations, :as_cast) do
      [] ->
        changeset_checks
      lists ->
        fields = Enum.concat(lists) |> Checks.Util.remove_fields_named_by_user(user_mentioned)
        changeset = insertion_changeset(example, fields)
        add_checks(changeset_checks, fields, changeset)
    end
  end


  defp add_checks(changeset_checks, all_fields, changeset) do
    named_in_changes? = &(&1 in Map.    keys(changeset.changes))
    named_in_errors?  = &(&1 in Keyword.keys(changeset.errors))

    fields = %{
      changes:    Enum.filter(all_fields, named_in_changes?),
      no_changes: Enum.reject(all_fields, named_in_changes?),
      errors:     Enum.filter(all_fields, named_in_errors?)
    }

    new_checks = %{
      changes: (for f <- fields.changes, do: {f, changeset.changes[f]}),
      no_changes: (for f <- fields.no_changes, do: f),
      errors: (for f <- fields.errors do
                {f, Keyword.get(changeset.errors, f) |> elem(0)}
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
