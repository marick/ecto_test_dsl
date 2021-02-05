defmodule EctoTestDSL.Parse.Node.ParamsLike do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AssertionJuice
  alias T.Parse.Node
  
  @moduledoc """
  """

  defstruct [:previous_name, overrides: %{}]

  def parse(previous_name, except: override_kws) do
    new(previous_name, override_kws)
  end
  
  def new(previous_name, override_kws) do
    overrides = Enum.into(override_kws, %{})
    %__MODULE__{overrides: overrides, previous_name: previous_name}
  end

  # ----------------------------------------------------------------------------

  defimpl Node.ParseTimeSubstitutable, for: Node.ParamsLike do
    def substitute(node, named_examples) do
      case Keyword.get(named_examples, node.previous_name) do
        nil ->
          ex = inspect node.previous_name
          elaborate_flunk("There is no previous example `#{ex}`",
            right: Map.keys(node.overrides))
        previous ->
          Node.Mergeable.merge(previous.params, Node.Params.new(node.overrides))
      end
    end
  end
end
