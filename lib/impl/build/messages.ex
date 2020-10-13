defmodule TransformerTestSupport.Impl.Messages do

  def should_be_valid(name),
    do: ~s/#{example name} #{is_in_category(:valid)}, #{but_marked("invalid")}/
  
  def should_be_invalid(name),
    do: ~s/#{example name} #{is_in_category(:invalid)}, #{but_marked("valid")}/

  defp example(name), do: "Example `#{inspect name}`"
  defp is_in_category(what), do: "is in category `#{inspect what}`"
  defp but_marked(string), do: "but the changeset is marked #{string}"

end
