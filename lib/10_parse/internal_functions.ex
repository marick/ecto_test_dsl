defmodule TransformerTestSupport.Parse.InternalFunctions do
  use TransformerTestSupport.Drink.Me

  defmacro id_of(extended_example_desc) do
    quote do
      een = een(unquote(extended_example_desc))
      FieldRef.new(id: een)
    end
  end
end
