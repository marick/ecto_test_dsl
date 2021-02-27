defmodule EctoTestDSL.Run.Reporting do
  def identify_example(name) do
    fn message -> context(name, message) end
  end

  def error_message(name, message, changeset) do
    """
    #{context(name, message)}
    Changeset: #{inspect changeset}
    """
  end

  defp context(name, message),
    do: "Example `#{inspect name}`: #{message}"
end
