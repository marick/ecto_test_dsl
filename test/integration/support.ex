defmodule Integration.Support do
  import Mockery.Macro
  use Mockery

  def tunable_insert(_repo, changeset) do
    mockable(__MODULE__).mockable_insert(changeset)
  end

  def mockable_insert(_changeset), do: "you forgot to mock the insertion"

  defmacro insert_returns(value) do
    quote do 
      mock(Integration.Support, :mockable_insert, unquote(value))
    end
  end

  defmacro __using__(_) do
    quote do 
      import Mockery.Macro
      use Mockery
      import Integration.Support
    end
  end
end
