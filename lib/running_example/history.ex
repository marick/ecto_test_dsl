defmodule TransformerTestSupport.RunningExample.History do
  alias TransformerTestSupport, as: T
  alias T.RunningExample.History
  
  defstruct data: []

  def new(example, opts) do 
    data =
      [repo_setup: Keyword.get(opts, :previously, %{}),
       example: example]
    struct(History, data: data)
  end
end
