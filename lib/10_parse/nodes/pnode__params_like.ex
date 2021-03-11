defmodule EctoTestDSL.Parse.Pnode.ParamsLike do
  use EctoTestDSL.Drink.Me
  use T.Drink.AndParse
  use T.Drink.Assertively
  alias Pnode.ParamsLike, as: This
  
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

  defimpl Pnode.Substitutable, for: This do
    def substitute(node, named_examples) do
      case Keyword.get(named_examples, node.previous_name) do
        nil ->
          ex = inspect node.previous_name
          elaborate_flunk("There is no previous example `#{ex}`",
            right: Map.keys(node.overrides))
        previous ->
          Pnode.Mergeable.merge(previous.params, Pnode.Params.parse(node.overrides))
      end
    end
  end
end
