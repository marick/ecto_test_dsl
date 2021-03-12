defmodule EctoTestDSL.Parse.InternalFunctions do
  use EctoTestDSL.Drink.Me
  alias T.MacroX
  alias T.Parse.BuildState

  # ----------------------------------------------------------------------------
  defmacro id_of(name_or_pair) do
    quote do
      een = een(unquote(name_or_pair))
      FieldRef.new(id: een)
    end
  end

  def module(), do: BuildState.examples_module

  def from(%EEN{} = een, opts), do: StructRef.new(een,                 opts)
  def from(atom,         opts), do: StructRef.new(een(atom, module()), opts)
  
  def from(%EEN{} = een),            do: from(een,                 [  ])
  def from([{name, module} | opts]), do: from(een(name, module  ), opts)
  def from(atom) when is_atom(atom), do: from(een(atom, module()), [  ])


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

  
  
end
