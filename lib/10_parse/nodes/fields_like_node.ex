defmodule EctoTestDSL.Parse.Node.FieldsLike do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AssertionJuice
  alias T.Parse.Node
  
  @moduledoc """
  """

  defstruct parsed: %{}, opts: [], with_ensured_eens: %{}, eens: []

  def parse(een_or_name, opts), do: new(een_or_name, opts)
  
  def new(een_or_name, opts) do
    parsed = %{een_or_name: een_or_name, opts: opts}
    %__MODULE__{parsed: parsed}
  end
    

  # ----------------------------------------------------------------------------

  defimpl Node.EENable, for: Node.FieldsLike do
    def eens(%{eens: eens}), do: eens
    def ensure_eens(node, default_module) do
      parsed = node.parsed
      reference_een = Node.Common.ensure_one_een(parsed.een_or_name, default_module)

      case Keyword.get(parsed.opts, :except) do
        nil ->
          eens = [reference_een]
          with_ensured_eens = %{reference_een: reference_een, opts: parsed.opts}
          %{node | eens: eens, with_ensured_eens: with_ensured_eens}
          
        except_value -> 
          other_eens = Node.Common.extract_een_values(except_value)
          eens = [reference_een | other_eens]
          with_ensured_eens = %{reference_een: reference_een, opts: parsed.opts}
          %{node | eens: eens, with_ensured_eens: with_ensured_eens}
      end      
    end
  end
end
