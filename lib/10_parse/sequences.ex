defmodule EctoTestDSL.Parse.Sequences do
  use EctoTestDSL.Drink.Me
  import Parse.ExampleFunctions

  @moduledoc """
  Sequences expand out into more basic functions
  """

  defmodule Util do 
    def sequence(seq) when is_list(seq), do: {:__flatten, seq}
  end

  def insert_twice(example_name) do 
      Util.sequence([
        previously(insert: example_name),
        params_like(example_name)
      ])
  end

  def blanks(names) do
    param_list = for n <- names, do: {n, ""}
    error_list = for n <- names, do: {n, "can't be blank"}

    Util.sequence([
      params(param_list),
      changeset(errors: error_list)
    ])
  end

end
