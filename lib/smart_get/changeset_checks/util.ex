defmodule TransformerTestSupport.SmartGet.ChangesetChecks.Util do
  alias TransformerTestSupport.SmartGet.Example
    
  @moduledoc """
  """

  def unique_fields(changeset_checks) do
    changeset_checks
    |> Enum.filter(&is_tuple/1)
    |> Keyword.values
    |> Enum.flat_map(&from_check_args/1)
    |> Enum.uniq
  end

  def from_check_args(field) when is_atom(field), do: [field]
  def from_check_args(list) when is_list(list), do: Enum.map(list, &field/1)
  def from_check_args(map)  when is_map(map), do: Enum.map(map,  &field/1)

  def field({field, _value}), do: field
  def field(field), do: field
    

  def remove_fields_named_by_user(default_fields, reject_fields) do
    Enum.reject(default_fields, &Enum.member?(reject_fields, &1))
  end

  # ----------------------------------------------------------------------------

  def separate_types_of_transformed_fields(example) do
    {as_cast_list, calculated_fields} =
      Example.field_transformations(example)
      |> Keyword.pop_values(:as_cast)
    
    [Enum.concat(as_cast_list), calculated_fields]
  end
  
end
