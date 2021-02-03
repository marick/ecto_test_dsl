defmodule EctoTestDSL.Parse.Node.ParamsLike do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AssertionJuice
  alias T.Parse.Node
  
  @moduledoc """
  """

  # This doesn't really need to be a struct, but having a named
  # thing is simpler than having an anonymous function floating around.

  defstruct [:resolver, :previous_name, overrides: []]

  def parse(previous_name, except: override_kws) do
    new(previous_name, override_kws)
  end
  
  def  new(previous_name, override_kws) do
    overrides = Enum.into(override_kws, %{})
    resolver = fn named_examples ->
      case Keyword.get(named_examples, previous_name) do
        nil ->
          ex = inspect previous_name
          elaborate_flunk("There is no previous example `#{ex}`",
            right: Keyword.keys(override_kws))
        previous -> 
          Map.merge(previous.params, overrides)
      end
    end

    %__MODULE__{resolver: resolver, overrides: override_kws, previous_name: previous_name}
  end

  def resolve(%__MODULE__{} = pl, existing_named_examples),
    do: pl.resolver.(existing_named_examples)

  def resolve(already_resolved, _) when is_map(already_resolved),
    do: already_resolved


  # ----------------------------------------------------------------------------

  def expand(new_named_examples, existing_named_examples) do
    starting_acc = %{expanded: [], existing: existing_named_examples}

    reducer = fn {new_name, new_example}, acc ->
      # Should write a map_second
      better =
        {new_name, expand_one(new_example, acc.existing)}

      %{expanded: [better | acc.expanded ], existing: [better | acc.existing]}
    end

    Enum.reduce(new_named_examples, starting_acc, reducer).expanded
  end
  
  defp expand_one(example, existing_named_examples) do
    resolve = &(resolve(&1, existing_named_examples))
    Map.update(example, :params, %{}, resolve)
  end

  defimpl Node.ParseTimeSubstitutable, for: Node.ParamsLike do
    def substitute(node, examples) do
      Node.ParamsLike.resolve(node, examples)
    end
  end

  
end
