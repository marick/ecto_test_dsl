defmodule Integration.Support do

  defmacro __using__(_) do
    quote do 
      import Mockery.Macro
      use Mockery

      def tunable_insert(_repo, changeset) do
        mockable(__MODULE__).mockable_insert(changeset)
      end

      def mockable_insert(_changeset), do: "you forgot to mock the insertion"

      defmacro insert_returns(value, in: module) do
        quote do 
          mock(unquote(module), :mockable_insert, unquote(value))
        end
      end
    end
  end
end
