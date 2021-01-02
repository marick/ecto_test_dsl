defmodule TransformerTestSupport do
  def start do
    TransformerTestSupport.TestDataServer.start
    TransformerTestSupport.Run.RunningExample.TraceServer.start
  end
end
