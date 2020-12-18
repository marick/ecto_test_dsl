defmodule TransformerTestSupport.SmartGet.ChangesetChecks.Util do
  alias TransformerTestSupport.SmartGet.Example
    
  @moduledoc """
  """

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
