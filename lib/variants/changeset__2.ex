defmodule TransformerTestSupport.Variants.Changeset__2 do

#  alias TransformerTestSupport.Impl.Build__2
      
  defmacro __using__(_) do
    quote do
      alias TransformerTestSupport.Variants.Changeset__2, as: Variant
      use TransformerTestSupport.Impl.Predefines__2
      import Variant
      
      alias TransformerTestSupport.Impl.Validations__2
      alias TransformerTestSupport.Impl.Get__2
    end
  end
end
