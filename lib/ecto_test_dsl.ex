defmodule EctoTestDSL do
  def start do
    EctoTestDSL.TestDataServer.start
    EctoTestDSL.TraceServer.start
  end
end
