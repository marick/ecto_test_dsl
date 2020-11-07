defmodule Test.Factory do
  use ExMachina


  def unique(prefix), do: sequence(prefix, &"#{to_string prefix}_#{&1}")
  
end
