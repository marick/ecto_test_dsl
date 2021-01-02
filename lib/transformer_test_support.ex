defmodule TransformerTestSupport do
  def start do
    TransformerTestSupport.TestDataServer.start
    TransformerTestSupport.TraceServer.start
  end
end
