defmodule EctoTestDSL.Run.Steps.Util do
  
  def context(name, message),
    do: "Example `#{inspect name}`: #{message}"

end
