defmodule EctoTestDSL.EnumX do
  def take_until(enumerable, f) do
    case Enum.find_index(enumerable, f) do
      nil -> enumerable
      index -> Enum.take(enumerable, index + 1)
    end
  end

  @doc """
  Like set difference, but order is preserved."
  """
  def difference(first, second) do
    Enum.reject(first, &Enum.member?(second, &1))
  end
  
end
