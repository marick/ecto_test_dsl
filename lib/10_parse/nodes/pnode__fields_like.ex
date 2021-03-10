defmodule EctoTestDSL.Parse.Pnode.FieldsLike do
  use EctoTestDSL.Drink.Me
  use T.Drink.AndParse
  use T.Drink.Assertively
  
  @moduledoc """
  """

  defstruct reference_een: nil, opts: [], eens: []

  def parse(een_or_name, opts), do: new(een_or_name, opts)
  
  def new(een_or_name, opts) do
    reference_een = reference_een(een_or_name)
    eens = extract_eens(reference_een, opts)
    %__MODULE__{
      reference_een: reference_een,
      opts: opts,
      eens: eens
    }
  end

  # Rethink allowing a plain name (not an een)
  defp reference_een(een_or_name) do 
    default_module = BuildState.examples_module
    Pnode.Common.ensure_one_een(een_or_name, default_module)
  end
    
  defp extract_eens(reference_een, opts) do
    case Keyword.get(opts, :except) do
      nil ->
        [reference_een]
        
      except_value -> 
        other_eens = Pnode.Common.extract_een_values(except_value)
        [reference_een | other_eens]
    end      
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
