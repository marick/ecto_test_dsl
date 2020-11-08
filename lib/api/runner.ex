defmodule TransformerTestSupport.Runner do
  alias TransformerTestSupport.SmartGet.Example

  # ----------------------------------------------------------------------------
  defmacro check_examples_with(module) do
    quote bind_quoted: [module: module] do
      Enum.each(module.test_data().examples |> Keyword.keys, fn example_name ->
        message = "#{inspect example_name} in #{inspect module}"
        name = ExUnit.Case.register_test(__ENV__, :example, message, [])
        def unquote(name)(_) do
          unquote(module).allow_asynchronous_tests(unquote(example_name))
          unquote(module).check_workflow(unquote(example_name))
        end
      end)
    end
  end

  defmacro check_examples_in_files(file_pattern) do
    quote do 
      for module <- tester_modules(unquote(file_pattern)),
        do: check_examples_with(module)
    end
  end
  
  # ----------------------------------------------------------------------------
  @module_name_regex ~r/^.*defmodule[\s]+([.\w]+)/
  
  def tester_modules(file_pattern) do
    for path <- Path.wildcard(file_pattern) do
      first_line = File.open!(path, [:read]) |> IO.read(:line)

      case Regex.run(@module_name_regex, first_line) do
        [_all, module_name] ->
          Module.safe_concat(module_name, "Tester")
        _ ->
          raise ~s/Could not find the module name inside file "#{path}"/
      end
    end
  end

  # ----------------------------------------------------------------------------

  def run_steps(example, opts \\ []) do
    opts = Enum.into(opts, %{})
    stop = Map.get(opts, :stop_after, :"this should not ever be a step name")
    starting_history = [example: example]

    attach_functions = fn step_names ->
      step_functions = Example.step_functions(example)
      for name <- step_names, do: {name, step_functions[name]}
    end

    example
    |> Example.step_list
    |> EnumX.take_until(&(&1 == stop))
    |> attach_functions.()
    |> run_steps(starting_history, example)
  end

  def run_steps([], history, _example), do: history
  def run_steps([{step_name, function} | rest], history, example) do
    value = function.(history, example)
    run_steps(rest, [{step_name, value} | history], example)
  end
end
