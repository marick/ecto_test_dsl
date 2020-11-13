defmodule TransformerTestSupport.RunningExample.History do
  alias TransformerTestSupport, as: T
  alias T.RunningExample.History
  
  def new(example, opts) do 
    [repo_setup: Keyword.get(opts, :previously, %{}),
     example: example]
  end

  def add(history, step_name, value) do
    [{step_name, value} | history]    
  end
end
