defmodule TransformerTestSupport.Variants.Changeset do

  defmacro __using__(_) do
    quote do
      alias TransformerTestSupport.Variants.Changeset, as: Variant
      use TransformerTestSupport.Impl.Predefines, Variant
    end
  end
end
