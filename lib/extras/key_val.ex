defmodule EctoTestDSL.KeyVal do

  def filter_by_value(kvs, predicate),
    do: Enum.filter(kvs, fn {_k, v} -> predicate.(v) end)
  def reject_by_value(kvs, predicate),
    do: Enum.reject(kvs, fn {_k, v} -> predicate.(v) end)

  def filter_by_key(kvs, predicate), 
    do: Enum.filter(kvs, fn {k, _v} -> predicate.(k) end)
  def reject_by_key(kvs, predicate), 
    do: Enum.reject(kvs, fn {k, _v} -> predicate.(k) end)

  @doc """
  By analogy to `map_reduce`, this `fetch`es a value then `map`s a function
  over it. The result is a List.
  """
  def fetch_map(kvs, f) do
    Enum.map(kvs, fn {_k, v} -> f.(v) end)
  end
end
