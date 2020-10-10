defmodule TransformerTestSupport do
  def start do
    TransformerTestSupport.Impl.TestDataServer.start
  end
end
