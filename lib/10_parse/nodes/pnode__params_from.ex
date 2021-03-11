defmodule EctoTestDSL.Parse.Pnode.ParamsFrom do
  use EctoTestDSL.Drink.Me
  use T.Drink.AndParse
  use T.Drink.Assertively
  alias Pnode.Common.EENWithOpts
  alias Pnode.ParamsFrom, as: This
  
  @moduledoc """
  """

  defstruct reference_een: nil, opts: [], eens: []

  def parse(%EEN{} = een, opts) do
    unless KeywordX.at_most_this_key?(opts, :except) do 
      elaborate_flunk(
        "`params_from`'s second argument must be `except: <keyword_list>`.",
        left: opts)
    end
    
    EENWithOpts.parse(This, een, opts)
  end
  
  def parse(not_een, _) do
    example_name = if is_atom(not_een), do: not_een, else: :some_name
    message =
      """
      The first argument to `params_from` must be an EEN.
      Perhaps you meant `een(#{to_string example_name}: #{inspect SomeExamples})`.
      """
    
    elaborate_flunk(message, left: not_een)
  end

  # ----------------------------------------------------------------------------

  defimpl Pnode.EENable, for: This do
    def eens(%{eens: eens}), do: eens
  end

  defimpl Pnode.Exportable, for: This do
    def export(node) do
      except = Keyword.get(node.opts, :except, []) |> Enum.into(%{})
      Rnode.ParamsFrom.new(node.reference_een, except)
    end
  end
end
