defmodule Given do
  import Mockery
  alias ExUnit.Assertions

  defmodule Util do
    # Note that this doesn't resolve aliases, which requires the __ENV__ at
    # macroexpansion time. Haven't figured out how to make use of that
    # information within a single function, so the caller will have to
    # adjust the result if the first part of the function is a module
    # alias.
    
    def decompose_call(funcall, default_module) do
      case Macro.decompose_call(funcall) do
        {{:__aliases__, _, aliases},  fun_atom, args} -> 
          composed_alias =
            Enum.reduce(aliases, :Elixir, fn alias, acc ->
              Module.safe_concat(acc, alias)
            end)
          function_description = [{fun_atom, length(args)}]

          {composed_alias, function_description, args}
          
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

    def key({module, function_description, arglist}) do
      {Given, module, function_description, arglist}
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

    # Note: This could be replaced by a `return_function_ast` that
    # uses `unquote_splicing` to construct a single function. However,
    # the function requires access to the compile-time __ENV__, so it
    # must be within a quote, and I don't know how to splice the
    # resulting AST into the `quote do`. Probably there's a way, or it
    # could be done by using data-manipulation functions (Map, List)
    # on the AST treated as a data stucture. But I've spent enough
    # time on this.
    #
    # Actual AST-creating code is commented out below.

    def return_function({module, function_description, arglist}) do
      fetcher = fn vars ->
        Given.Util.process_fetch!({Given, module, function_description, vars})
      end

      case length(arglist) do
        0 -> fn                        -> fetcher.([                      ]) end
        1 -> fn a1                     -> fetcher.([a1                    ]) end
        2 -> fn a1, a2                 -> fetcher.([a1, a2                ]) end
        3 -> fn a1, a2, a3             -> fetcher.([a1, a2, a3            ]) end
        4 -> fn a1, a2, a3, a4         -> fetcher.([a1, a2, a3, a4        ]) end
        5 -> fn a1, a2, a3, a4, a5     -> fetcher.([a1, a2, a3, a4, a5    ]) end
        6 -> fn a1, a2, a3, a4, a5, a6 -> fetcher.([a1, a2, a3, a4, a5, a6]) end
        _ ->
          Assertions.flunk(
            """
            For essentially arbitrary reasons, `given` works only for
            functions with six or fewer args. This is easily changed.
            """)
      end
    end

    # @args [:a1, :a2, :a3, :a4, :a5, :a6, :a7, :a8, :a9, :aa, :ab, :ac, :ad, :ae, :af]

    # def return_function_ast({module, function_description, arglist}) do
    #   vars = for a <- Enum.take(@args, length(arglist)), do: Macro.var(a, __MODULE__)

    #   quote do 
    #     fn unquote_splicing(vars) ->
    #       Given.Util.process_fetch!({
    #         Given,
    #         unquote(module),
    #         unquote(function_description),
    #         unquote(vars)
    #       })
    #     end
    #   end
    # end
    
  end


  
  
  defmacro given(funcall, return: body) do
    {aliass, function_description, arglist} = 
      Given.Util.decompose_call(funcall, __MODULE__)

    quote do
      module = Keyword.get(__ENV__.aliases, unquote(aliass), unquote(aliass))
      triple = {module, unquote(function_description), unquote(arglist)}

      key = Given.Util.key(triple)
      value_calculator = Util.return_function(triple)
      Process.put(key, unquote(body))
      mock(module, unquote(function_description), value_calculator)
    end
  end

  defmacro __using__(_) do
    quote do
      require Given
      import Given
    end
  end
end
