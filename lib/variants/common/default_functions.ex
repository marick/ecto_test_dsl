defmodule EctoTestDSL.Variants.Common.DefaultFunctions do
  use EctoTestDSL.Drink.Me
  import ExUnit.Assertions
  
  def plain_changeset(schema, struct, params),
    do: schema.changeset(struct, params)
  
  def params_only_changeset(~M{schema}, formatted_params) do
    default_struct = struct(schema)
    schema.changeset(default_struct, formatted_params)
  end

  def primary_key_from_id_param(%{params: params}) do
    message = to_learn_more("""
      By default, the primary key of the entity to be updated is taken
      to be the value of key "id" in the form parameters. There is no
      such key. 

      You probably need to set `:get_primary_key_with` in your `start` function.
      """)

    primary_key = Map.get(params, "id")
    assert primary_key, message
    primary_key
  end
  

  def checked_get(~M{repo, schema, primary_key, set_hint}) do
    message = to_learn_more("""
     Could not fetch a #{inspect schema} with primary key `#{primary_key}`.
     You may need to set `#{inspect set_hint}` in your `start` function.
     """)

    result = repo.get(schema, primary_key) 
    assert result, message
    result
  end

  def plain_insert(repo, changeset), do: repo.insert(changeset)
  def plain_update(repo, changeset), do: repo.update(changeset)


  defp to_learn_more(msg) do
    """
    #{msg}
    To learn more, see the documentation or look at your variant's
    definition of `default_start_opts`.
    """
  end
end
