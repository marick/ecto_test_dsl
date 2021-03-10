defmodule EctoTestDSL.Parse.Pnode.ParamsFromRepo do
  use EctoTestDSL.Drink.Me
  use T.Drink.AndParse
  use T.Drink.Assertively
  
  @moduledoc """
  """

  defstruct reference_een: nil, except: [], eens: []

  def parse(%EEN{} = een, except: except),
    do: new(een, Enum.into(except, %{}))
  
  def parse(not_een, except: _except) do
    example_name = if is_atom(not_een), do: not_een, else: :some_name
    message =
      """
      The first argument to `params_from_repo` must be an EEN.
      Perhaps you meant `een(#{to_string example_name}: #{inspect SomeExamples})`.
      """
    
    elaborate_flunk(message, left: not_een)
  end
  
  def parse(_een, opts) do
    message =
      """
      `params_from_repo`'s second argument must be `except: <keyword_list>`.
      """
    
    elaborate_flunk(message, left: opts)
  end
  
  
  def new(reference_een, except) do
    eens = [reference_een | Pnode.Common.extract_een_values(except)]
    ~M{%__MODULE__ reference_een, except, eens}
  end

  # ----------------------------------------------------------------------------

  defimpl Pnode.EENable, for: Pnode.ParamsFromRepo do
    def eens(%{eens: eens}), do: eens
  end

  defimpl Pnode.Exportable, for: Pnode.ParamsFromRepo do
    def export(node) do
      Rnode.ParamsFromRepo.new(node.reference_een, node.except)
    end
  end
end
