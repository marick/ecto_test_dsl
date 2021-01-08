defmodule Given do
  import Mockery

  defmodule Util do
    def decompose_call(funcall, default_module) do
      case Macro.decompose_call(funcall) do
        {{:__aliases__, _, aliases},  fun_atom, args} -> 
          composed_module =
            Enum.reduce(aliases, :Elixir, fn alias, acc ->
              Module.safe_concat(acc, alias)
            end)
          function_description = [{fun_atom, length(args)}]

          {composed_module, function_description, args}
          
        {fun_atom, args} ->
          function_description = [{fun_atom, length(args)}]
          {default_module, function_description, args}
          
          _ ->
        raise """
        #{Macro.to_string(funcall)} does not look like a call to a function
        attached to a module.
        """
      end
    end

    def key_ast({module, function_description, arglist}) do
      quote do 
        {Given, unquote(module), unquote(function_description), unquote(arglist)}
      end
    end

    def return_function_ast({module, function_description, arglist} = key) do
      quote do 
        fn a, b ->
          Process.get{Given, unquote(module), unquote(function_description), [a, b]}
        end
      end
    end
  end
  
  defmacro given(funcall, return: body) do
    {module, function_description, arglist} = triple = 
      Given.Util.decompose_call(funcall, __MODULE__)

    key = Util.key_ast(triple)
    value_calculator = Util.return_function_ast(triple)

    quote do
      Process.put(unquote(key), unquote(body))
      mock(unquote(module), unquote(function_description), unquote(value_calculator))
    end
  end
    

  # @doc """
  # Mockery support

  # given Module.function, [args...], do: return-value
  # """

  # defmacro given(modulename, args, do: body) do
  #   {{:., _, [module, fn_name]},
  #     _, _
  #   } = modulename

  #   fn_descriptor = [{fn_name, length(args)}]

  #   quote do
  #     mock(unquote(module), unquote(fn_descriptor), fn(unquote_splicing(args)) ->
  #       unquote(body)
  #     end)
  #   end
  # end

  defmacro __using__(_) do
    quote do
      require Given
      import Given
    end
  end
end
