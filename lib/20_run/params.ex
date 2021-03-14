defmodule EctoTestDSL.Run.Params do
  use EctoTestDSL.Drink.Me
  alias Formats.Phoenix
  alias T.Nouns.Example
  alias ExUnit.Assertions

  def format(params, how) do
    formatters = %{
      raw: &(&1),
      phoenix: &Phoenix.format/1
    }

    case Map.get(formatters, how) do
      nil -> 
        Assertions.flunk """
        `#{inspect how}` is not a valid format for test data params.
        Try one of these: `#{inspect Map.keys(formatters)}`
        """
      formatter ->
        formatter.(params)
    end
  end

  def format_for_example(params, example) do
    format(params, Example.format(example))
  end
end
