defmodule EctoTestDSL.Run.Reporting do
  def identify_example(name) do
    fn message -> context(name, message) end
  end

  def changeset_error_message(name, message, changeset) do
    """
    #{context(name, message)}
    Changeset: #{inspect changeset}
    """
  end

  def schema_error_message(name, message, struct) do
    """
    #{context(name, message)}
    Whole structure: #{inspect struct}
    """
  end

  def context(name, message),
    do: "Example `#{inspect name}`: #{message}"
end
