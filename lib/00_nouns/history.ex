defmodule EctoTestDSL.Nouns.History do
  
  def new(example, opts \\ []) do 
    [repo_setup: Keyword.get(opts, :repo_setup, %{}),
     example: example]
  end

  def add(history, value_source, value) do
    [{value_source, value} | history]    
  end

  def trivial(step_value_list \\ []), do: step_value_list


  def fetch!(history, value_source),
    do: Keyword.fetch!(history, value_source)
end
