defmodule EctoTestDSL.Runner do
  use EctoTestDSL.Drink.Me

  # ----------------------------------------------------------------------------
  defmacro check_examples_with(module, opts \\ []) do
    show_names = Keyword.get(opts, :show_names, false)
    quote bind_quoted: [module: module, show_names: show_names] do
      Enum.each(module.test_data().examples |> Keyword.keys, fn example_name ->
        message = "#{inspect example_name} in #{inspect module}"
        name = ExUnit.Case.register_test(__ENV__, :example, message, [])
        def unquote(name)(_) do
          if unquote(show_names), do: IO.inspect(unquote(message))
          unquote(module).check_automatic_only(unquote(example_name))
        end
      end)
    end
  end

  defmacro check_examples_in_files(file_pattern, opts \\ []) do
    quote do 
      for module <- tester_modules(unquote(file_pattern)) do
        check_examples_with(module, unquote(opts))
        if Keyword.get(unquote(opts), :show_names, false), do: IO.puts("\n")
      end
    end
  end
  
  # ----------------------------------------------------------------------------
  @module_name_regex ~r/^.*defmodule[\s]+([.\w]+)/
  
  def tester_modules(file_pattern) do
    for path <- Path.wildcard(file_pattern) do
      first_line = File.open!(path, [:read]) |> IO.read(:line)

      case Regex.run(@module_name_regex, first_line) do
        [_all, module_name] ->
         try do 
            Module.safe_concat(module_name, "Tester")
          rescue ex in ArgumentError ->
            message = """
            Module #{module_name} is not available.
            Most likely, its directory wasn't added to the mix.exs compile path, 
            which should look something like this:
                defp elixirc_paths(:test), do: ["lib", "test", "test/examples"]
                                                               ^^^^^^^^^^^^^^^
           """                                                               
            IO.puts message
            reraise ex, __STACKTRACE__
          end
        _ ->
          raise ~s/Could not find the module name inside file "#{path}"/
      end
    end
  end
end
