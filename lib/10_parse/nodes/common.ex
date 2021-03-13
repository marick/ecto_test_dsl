defmodule EctoTestDSL.Parse.Pnode.Common do
  use EctoTestDSL.Drink.Me
  use T.Drink.Assertively
  alias T.Nouns.RefHolder

  defmodule FromPairs do
    def parse(module, kvs) do
      map = Enum.into(kvs, %{})
      
      struct(module,
        parsed: map,
        eens: extract_een_values(map))
    end

    def merge(module, one, two) do
      struct(module,
        parsed: Map.merge(one.parsed, two.parsed),
        eens: one.eens ++ two.eens)
    end

    def extract_een_values(kvs) do
      Enum.flat_map(kvs, fn {_key, value} -> extract_from_one_value(value) end)
    end

    def extract_from_one_value(value) do
      cond do
        RefHolder.impl_for(value) -> 
          RefHolder.eens(value)
        is_map(value) ->
          extract_een_values(value)
        KeywordX.is_keyword_list(value) ->
          Enum.flat_map(value, &extract_een_values/1)
        is_list(value) ->
          Enum.flat_map(value, &extract_from_one_value/1)
        true ->
          []
      end
    end
  end


  # This only parses EENs out the :except option. The other options
  # are expected not to contain EENs. That's the case when the options
  # are sent to `MapA.assert_same_map`. But maybe it wouldn't hurt to
  # check them all?
  defmodule EENWithOpts do
    def parse(module, een, opts) do
      struct(module,
        reference_een: een,
        opts: opts,
        eens: [een | except_eens(opts)])
    end

    defp except_eens(opts) do
      opts
      |> Keyword.get(:except, [])
      |> FromPairs.extract_een_values()
    end      
  end

  defmodule NameOrEEN do
    def lift(%EEN{} = een, _default_module), do: een
    def lift(atom, default_module), do: EEN.new(atom, default_module)
  end
end

  
