defmodule EctoTestDSL.Parse.Pnode.FieldsLike do
  use EctoTestDSL.Drink.Me
  use T.Drink.AndParse
  use T.Drink.Assertively

  alias Pnode.Common.EENWithOpts
  
  @moduledoc """
  """

  defstruct reference_een: nil, opts: [], eens: []

  def parse(een_or_name, opts) do
    reference_een = reference_een(een_or_name)
    EENWithOpts.parse(Pnode.FieldsLike, reference_een, opts)
  end

  # Rethink allowing a plain name (not an een)
  defp reference_een(een_or_name) do 
    default_module = BuildState.examples_module
    Pnode.Common.ensure_one_een(een_or_name, default_module)
  end
    
  # ----------------------------------------------------------------------------

  defimpl Pnode.EENable, for: Pnode.FieldsLike do
    def eens(%{eens: eens}), do: eens
  end

  defimpl Pnode.Exportable, for: Pnode.FieldsLike do
    def export(node) do
      Rnode.FieldsLike.new(node.reference_een, node.opts)
    end
  end
end
