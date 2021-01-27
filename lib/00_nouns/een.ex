defmodule EctoTestDSL.Nouns.EEN do

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


  defmodule Macros do
    alias EctoTestDSL.Nouns.EEN
  
    defmacro een([{example_name, module}]) do 
      quote do
        EEN.new(unquote(example_name), unquote(module))
      end
    end
    
    defmacro een(example_name) do
      quote do
        EEN.new(unquote(example_name), __MODULE__)
      end
    end
    
    defmacro een(example_name, module) do 
      quote do
        EEN.new(unquote(example_name), unquote(module))
      end
    end
  end
end
