defmodule EnumX do
  def take_until(enumerable, f) do
    case Enum.find_index(enumerable, f) do
      nil -> enumerable
      index -> Enum.take(enumerable, index + 1)
    end
  end
end
