defmodule TransformerTestSupport.Build do
  use TransformerTestSupport.Drink.Me

  @moduledoc """
  """


  def step(f, key) do
    fn running ->
      Keyword.fetch!(running.history, key) |> f.()
    end
  end
  

  # ----------------------------------------------------------------------------


  # ----------------------------------------------------------------------------







end
