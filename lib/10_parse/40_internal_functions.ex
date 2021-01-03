defmodule TransformerTestSupport.Parse.InternalFunctions do
  use TransformerTestSupport.Drink.Me

  # ----------------------------------------------------------------------------
  defmacro id_of(extended_example_desc) do
    quote do
      een = een(unquote(extended_example_desc))
      FieldRef.new(id: een)
    end
  end

  # ----------------------------------------------------------------------------
  defmacro on_success(funcall) do
    from = "on_success(#{Macro.to_string(funcall)})"
    case Macro.decompose_call(funcall) do
      {{:__aliases__, _, aliases},  fun_atom, args} -> 
        composed_module = Enum.reduce(aliases, :Elixir, fn alias, acc ->
          Module.safe_concat(acc, alias)
        end)
        fun = Function.capture(composed_module, fun_atom, length(args))
        quote do
          FieldCalculator.new(unquote(fun), unquote(args), unquote(from))
        end

      {fun_atom, args} ->
        quote do 
          fun = Function.capture(__MODULE__, unquote(fun_atom), length(unquote(args)))
          FieldCalculator.new(fun, unquote(args), unquote(from))
        end

      _ ->
        raise """
        The argument to `on_success/1` does not look like a function call.
        You may want the `on_success(f, applied_to: args)` variant.
        """
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