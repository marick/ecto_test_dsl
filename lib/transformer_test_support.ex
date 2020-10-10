defmodule TransformerTestSupport do
  def start do
    TransformerTestSupport.Impl.Agent.start
    TransformerTestSupport.Impl.TestDataServer.start
  end
end
