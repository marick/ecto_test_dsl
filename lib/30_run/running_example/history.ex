defmodule TransformerTestSupport.Run.RunningExample.History do
  # alias TransformerTestSupport, as: T
  
  def new(example, opts) do 
    [previously: Keyword.get(opts, :previously, %{}),
     example: example]
  end

  def add(history, step_name, value) do
    [{step_name, value} | history]    
  end

  def trivial(step_value_list \\ []), do: step_value_list


  def step_value!(history, step_name),
    do: Keyword.fetch!(history, step_name)
end
