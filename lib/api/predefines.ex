defmodule TransformerTestSupport.Predefines do
  @moduledoc """
  """

  defmacro __using__(_) do
    quote do
      alias TransformerTestSupport, as: T
      alias T.Impl
      import T.Build, except: [start: 1]  # Variant must define `start`.
      alias T.Build
      alias T.{Get,Validations}
      alias T.SmartGet
    end
  end
end
