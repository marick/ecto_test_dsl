defmodule EctoTestDSL.Nouns.History do
  
  def new(example, opts \\ []) do 
    [previously: Keyword.get(opts, :previously, %{}),
     example: example]
  end

  def add(history, value_source, value) do
    [{value_source, value} | history]    
  end

  def trivial(step_value_list \\ []), do: step_value_list


  def fetch!(history, value_source),
    do: Keyword.fetch!(history, value_source)
end
