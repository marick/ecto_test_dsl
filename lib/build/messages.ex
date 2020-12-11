defmodule TransformerTestSupport.Messages do
  

  def should_be_valid(name),
    do: ~s/#{example name} #{is_in_workflow(:valid)}, #{but_marked("invalid")}/
  
  def should_be_invalid(name),
    do: ~s/#{example name} #{is_in_workflow(:invalid)}, #{but_marked("valid")}/

  def invalid_keys(), do: "Required keys are missing or extra keys are present"

  def missing_een(een),
    do: "There is no example named #{inspect een}"
  # ----------------------------------------------------------------------------

  defp example(name), do: "Example `#{inspect name}`"
  defp is_in_workflow(what), do: "is in workflow `#{inspect what}`"
  defp but_marked(string), do: "but the changeset is marked #{string}"


end
