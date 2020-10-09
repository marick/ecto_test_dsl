defmodule TransformerTestSupport.Macros do

  defmacro check_examples_with(module) do
    quote bind_quoted: [module: module] do
      Enum.each(module.test_data().examples |> Keyword.keys, fn example_name ->
        message = "#{inspect example_name} in #{inspect module}"
        name = ExUnit.Case.register_test(__ENV__, :example, message, [])
        def unquote(name)(_), do: unquote(module).validate(unquote(example_name))
      end)
    end
  end
end
