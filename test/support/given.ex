defmodule Given do
  import Mockery
  alias ExUnit.Assertions

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

    def process_fetch!(key) do
      case Process.get(key, :__missing_process_key) do
        :__missing_process_key ->
          {_, module, [{function_name, _}], arglist} = key
          arg_string =
            arglist
            |> Enum.map(&inspect/1)
            |> Enum.join(", ")
          funcall = "#{inspect module}.#{to_string function_name}(#{arg_string})"
            
          Assertions.flunk("You did not set up a stub for #{funcall}")
        value ->     
          value
      end
    end
    

    @args [:a1, :a2, :a3, :a4, :a5, :a6, :a7, :a8, :a9, :aa, :ab, :ac, :ad, :ae, :af]

    def return_function_ast({module, function_description, arglist}) do
      vars = for a <- Enum.take(@args, length(arglist)), do: Macro.var(a, __MODULE__)

      quote do 
        fn unquote_splicing(vars) ->
          Given.Util.process_fetch!({
            Given,
            unquote(module),
            unquote(function_description),
            unquote(vars)
          })
        end
      end
    end
  end
  
  defmacro given(funcall, return: body) do
    {module, function_description, _arglist} = triple = 
      Given.Util.decompose_call(funcall, __MODULE__)

    key = Util.key_ast(triple)
    value_calculator = Util.return_function_ast(triple)

    quote do
      Process.put(unquote(key), unquote(body))
      mock(unquote(module), unquote(function_description), unquote(value_calculator))
    end
  end

  defmacro __using__(_) do
    quote do
      require Given
      import Given
    end
  end
end
