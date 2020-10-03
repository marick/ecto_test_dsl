defmodule TransformerTestSupport.Impl.Build do

  @moduledoc """
  """

  def build_defaults do
    %{
      examples: [],
      accept_example: fn _ ->
        raise("Either the variant or the param code must define function `:accept_example`.")
      end,
    }
  end

       

  def create_test_data(keywords) when is_list(keywords),
    do: keywords |> Enum.into(%{}) |> create_test_data

  def create_test_data(map) when is_map(map) do
    start =
      Map.merge(build_defaults(), map)

    expanded_examples =
      Enum.reduce(start.examples, %{}, &add_real_example/2)

    Map.put(start, :examples, expanded_examples)
  end

  def to_strings(map) when is_map(map), do: map_to_strings(map)
  def to_strings(kws) when is_list(kws), do: Enum.into(kws, %{}) |> to_strings

  def like(original, except: map) when is_map(map),
    do: {:__like, original, to_strings(map)}
  def like(original, except: kws) when is_list(kws), 
    do: like(original, except: Enum.into(kws, %{}))
  def like(original), do: like(original, except: [])

  # ----------------------------------------------------------------------------

  def add_real_example({new_name, %{params: params} = raw_data}, acc) do
    expanded_params =
      case params do
        {:__like, earlier_name, overriding_params} ->
          case acc[earlier_name] do
            nil ->
              raise("Build.like/2: there is no example named `#{inspect earlier_name}`")
            example -> 
              Map.merge(example.params, overriding_params)
          end
        _ ->
          params
      end
    expanded_data = Map.put(raw_data, :params, expanded_params)
    Map.put(acc, new_name, expanded_data)
  end


  # ----------------------------------------------------------------------------

  
  defp map_to_strings(map) when is_map(map) do
    map
    |> Enum.map(fn {k,v} -> {value_to_string(k), value_to_string(v)} end)
    |> Map.new
  end

  defp value_to_string(value) when is_list(value),
    do: Enum.map(value, &to_string/1)
  defp value_to_string(value) when is_map(value),
    do: map_to_strings(value)
  defp value_to_string(value),
      do: to_string(value)
end
