defmodule TransformerTestSupport.Predefines do
  @moduledoc """
  """

  defmacro __using__(_) do
    quote do
      alias TransformerTestSupport, as: T
      alias T.Impl
      use T.Parse.All
      
      alias T.{Get,Validations}
    end
  end
end
