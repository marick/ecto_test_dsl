defmodule Given do
  import Mockery
  alias ExUnit.Assertions
  alias EctoTestDSL.MacroX
  alias Given.Util

  @moduledoc """
  A shorthand notation for `Mockery` that makes more pretty the common case
  of returning a specific return value for a given set of arguments, as
  in:

      use Given
      given Map.get(%{}, :key), return: "5"

  Note that the first argument to `given` looks like an ordinary function call.

  It is also common to have a "don't care" argument, like this:

      given Map.get(@any, :key), return: "5"

  See `given/2` for more.
  """
  
  @doc """
  Takes what looks like a function call, plus a return value, and arranges that
  such a function call will return the given value whenever it's made at a
  ["seam"](https://www.informit.com/articles/article.aspx?p=359417&seqNum=2)
  marked with `Mockery.mockable/1`. 

      # Code:
      ... mockable(Schema).changeset(struct, params) ...

      # Test: 
      given Schema.changeset(%Schema{}, %{age: "3"}), return: %Changeset{...}

  The function's arguments and return value can be constants, as shown
  above, or they can be calculations or variables. That can be helpful
  when the `given` appears in a test helper:

      def helper(params, cast_value, something_else) do 
        ...
        given Schema.changeset(%Schema{}, params), return: cast_value
        ...
        assert ...
      end

  A function argument can be the special value `@any` (defined when
  the module is `used`). That's useful when the argument is irrelevant
  and you don't want to have to type it out:

        given Schema.changeset(@any, params), return: cast_value

  `@any` expands to a function whose value is always `true`. More generally,
  any function used as an argument is not matched with equality. Instead, the
  call-time value is passed to the function, which should return a truthy value
  to indicate a match. So you can do this:

        given Module.f(5, &even/1), return: 8

  Notes:
  * You can provide return values for many arglist values. 
    
        given Module.f(5, &even/1), return: 8
        given Module.f(6, @any),    return: 9

  * If there's more than one match, the first is used.

  * If the same arglist is given twice, the second replaces the first.
    This is useful for `setup` methods:

        def setup do  
          given RunningExample.params(:a_runnable), return: %{}
          ...

        test "..."
          given RunningExample.params(:a_runnable), return: %{"a" => "1"}
          assert Steps.runnable(:a_runnable) == %{a: 1}
        end

  * If a function has a `given` value for one or more arglists, but none
    matched, an error is thrown.
  """
  
  defmacro given(funcall, return: value) do
    {_, the_alias, name_and_arity, arglist_spec} = 
      MacroX.decompose_call_alt(funcall)

    expand(the_alias, name_and_arity, arglist_spec, value)
  end

  @doc """
  The guts of `given/2` for use in your own macros.

  This function is convenient when you want to create a number of mocks at
  once. For example, suppose the `RunningExample` module has several single-argument
  getters. A `stub` macro can be more compact than several `givens`:

      stub(
        original_params: input,
        format:          :phoenix,
        neighborhood:    %{een(b: Module) => %{id: 383}})
      
  `stub` can be written like this:

      defmacro stub(kws) do
        for {key, val} <- kws do
          Given.expand(RunningExample, [{key, 1}], [:running], val)
        end
      end

  In the following, `module_alias` can be a simple atom, like `RunningExample`,
  which is an alias for `EctoTestDSL.Run.RunningExample`. More generally, it
  can be the `:__aliases__` value from `Macro.decompose_call/1`. 

  `name_and_arity` is a function name and arity pair of the form `[get: 3]`.

  `arglist_spec` is a list of values like `[5, @any]`, and
  `return_value` is any value.
  """
  def expand(module_alias, name_and_arity, arglist_spec, return_value) do
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

  # ----------------------------------------------------------------------------

  defmodule Util do
    def process_dictionary_key(module, function_description),
      do: {Given, module, function_description}

    defp new_stub(arglist_spec, return_value),
      do: {arglist_spec, return_value, make_matcher(arglist_spec)}

    def add_stub(process_key, arglist_spec, return_value) do
      stubs_except = fn stubs, new_spec -> 
        stubs
        |> Enum.reject(fn {old_spec, _, _} -> new_spec == old_spec end)
      end
      
      older_stubs =
        process_key
        |> Process.get([])
        |> stubs_except.(arglist_spec)

      process_key
      |> Process.put(older_stubs ++ [new_stub(arglist_spec, return_value)])
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

    # ----------------------------------------------------------------------------
    # Note: This could be replaced by a version that
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

    def any(_v), do: true
  end
  
end
