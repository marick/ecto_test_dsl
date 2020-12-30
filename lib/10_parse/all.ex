defmodule TransformerTestSupport.Parse.All do

  @moduledoc """
  """

  defmacro __using__(_) do
    quote do
      import TransformerTestSupport.Parse.TopLevel
      import TransformerTestSupport.Parse.ExampleFunctions
      import TransformerTestSupport.Parse.InternalFunctions
    end
  end
end
