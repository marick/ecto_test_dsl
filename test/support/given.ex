defmodule Given do
  import Mockery
  alias ExUnit.Assertions
  alias EctoTestDSL.MacroX

  defmodule Util do
    def process_dictionary_key(module, function_description) do
      {Given, module, function_description}
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

    def make__return_calculator(process_key, [{_name, arity}]) do
      fetcher = fn arg_values ->
        Given.Util.stubbed_value!(process_key, arg_values)
      end

      case arity do
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


    defp stubs_without(process_key, new_spec) do
      Process.get(process_key, [])
      |> Enum.reject(fn {old_spec, _, _} -> new_spec == old_spec end)
    end

    def add_stub(process_key, arglist_spec, return_value) do
      matcher = make_matcher(arglist_spec)
      existing = stubs_without(process_key, arglist_spec)
      Process.put(process_key, existing ++ [{arglist_spec, return_value, matcher}])
      :ok
    end

    def stubbed_value!(process_key, arg_values) do
      stubs = Process.get(process_key, :__missing_function)
      if stubs == :__missing_function do
        {_, module, [{function_name, arity}]} = process_key
        funcall =
          "&#{inspect module}.#{to_string function_name}/#{to_string arity}"
        Assertions.flunk("You did not set up any stubs for #{funcall}")
      end

      finder = fn {_, _, matcher} -> matcher.(arg_values) end
      case Enum.find(stubs, finder) do
        {_, return_value, _} -> 
          return_value
        _ -> 
          {_, module, [{function_name, _}]} = process_key
          arg_string =
            arg_values
            |> Enum.map(&inspect/1)
            |> Enum.join(", ")
          funcall = "#{inspect module}.#{to_string function_name}(#{arg_string})"
            
          Assertions.flunk("You did not set up a stub for #{funcall}")
      end
    end

    def make_matcher(arglist_spec) do
      check = fn {value, spec} ->
        FlowAssertions.MiscA.good_enough?(value, spec)
      end
      
      fn arglist_values ->
        Enum.zip(arglist_values, arglist_spec)
        |> Enum.all?(check)
      end
    end

    def any(_v), do: true
  end

  defmacro given(funcall, return: value) do
    {_, the_alias, name_and_arity, arglist_spec} = 
      MacroX.decompose_call_alt(funcall)

    expand_given(the_alias, name_and_arity, arglist_spec, value)
  end

  def expand_given(module_alias, name_and_arity, arglist_spec, return_value) do
    quote do
      module = MacroX.alias_to_module(unquote(module_alias), __ENV__)
      process_key = Given.Util.process_dictionary_key(module, unquote(name_and_arity))
      Given.Util.add_stub(process_key, unquote(arglist_spec), unquote(return_value))
      
      return_calculator = Given.Util.make__return_calculator(process_key, unquote(name_and_arity))
      mock(module, unquote(name_and_arity), return_calculator)
    end
  end

  defmacro __using__(_) do
    quote do
      import Given, only: [given: 2]

      @any &Util.any/1
    end
  end
end
