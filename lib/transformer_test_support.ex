defmodule TransformerTestSupport do
  def start do
    TransformerTestSupport.TestDataServer.start
    TransformerTestSupport.RunningExample.TraceServer.start
  end
end
