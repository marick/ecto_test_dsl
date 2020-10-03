defmodule TransformerTestSupport do
  def start do
    TransformerTestSupport.Impl.Agent.start
  end
end
