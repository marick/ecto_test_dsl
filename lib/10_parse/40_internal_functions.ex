defmodule TransformerTestSupport.Parse.InternalFunctions do
  use TransformerTestSupport.Drink.Me
  alias T.MacroX

  # ----------------------------------------------------------------------------
  defmacro id_of(extended_example_desc) do
    quote do
      een = een(unquote(extended_example_desc))
      FieldRef.new(id: een)
    end
  end

  # ----------------------------------------------------------------------------

  # Clearly some more duplication could be removed, but that's enough for now.
  
  defmacro on_success(funcall) do
    from = "on_success(#{Macro.to_string(funcall)})"
    case MacroX.decompose_call_alt(funcall) do
      {:in_named_module, alias_or_module, [{fun_atom, fun_count}], args} ->
        quote do
          module = MacroX.alias_to_module(unquote(alias_or_module), __ENV__)
          fun = Function.capture(module, unquote(fun_atom), unquote(fun_count))
          FieldCalculator.new(fun, unquote(args), unquote(from))
        end

      {:in_calling_module, _, [{fun_atom, fun_count}], args} ->
        quote do 
          module = MacroX.alias_to_module(__MODULE__, __ENV__)   # NO-OP
          fun = Function.capture(module, unquote(fun_atom), unquote(fun_count))
          FieldCalculator.new(fun, unquote(args), unquote(from))
        end
    end
  end

  def on_success(f, applied_to: fields) when is_list(fields),
    do: FieldCalculator.new(f, fields, "on_success(<fn>, applied_to: #{inspect fields})")
  def on_success(f, applied_to: field),
      do: on_success(f, applied_to: [field])

  
  # ----------------------------------------------------------------------------

  # Used to create arguments for TopLevel.replace_steps
  def step(f, key) do
    fn running ->
      Keyword.fetch!(running.history, key) |> f.()
    end
  end
  
end
