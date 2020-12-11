defmodule TransformerTestSupport.Types.EEN do

  @moduledoc """
  An Extended Example Name.
  """

  defstruct [:name, :module]

  def new(name, module) do
    %__MODULE__{name: name, module: module}
  end


  defimpl Inspect, for: __MODULE__ do
    def inspect(een, _opts) do
      shorthand = Module.split(een.module) |> List.last
      "`#{inspect een.name}` in #{shorthand}"
    end
  end
end
