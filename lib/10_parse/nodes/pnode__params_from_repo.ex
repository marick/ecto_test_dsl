defmodule EctoTestDSL.Parse.Pnode.ParamsFromRepo do
  use EctoTestDSL.Drink.Me
  use T.Drink.AndParse
  use T.Drink.AssertionJuice
  
  @moduledoc """
  """

  defstruct parsed: %{}, with_ensured_eens: %{}, eens: []

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
  
  
  def new(een, except) do
    parsed = %{een: een, except: except}
    %__MODULE__{parsed: parsed}
  end
    

  # ----------------------------------------------------------------------------

  defimpl Pnode.EENable, for: Pnode.ParamsFromRepo do
    def eens(%{eens: eens}), do: eens
    def ensure_eens(node, _default_module) do
      parsed = node.parsed
      eens = [parsed.een | Pnode.Common.extract_een_values(parsed.except)]
      %{node | eens: eens, with_ensured_eens: parsed}
    end
  end


  defimpl Pnode.Exportable, for: Pnode.ParamsFromRepo do
    def export(~M{with_ensured_eens}) do
      Rnode.ParamsFromRepo.new(with_ensured_eens.een, with_ensured_eens.except)
    end
  end
end
