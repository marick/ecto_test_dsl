defmodule EctoTestDSL.MacroX do

    # Note that this doesn't resolve aliases, which requires the __ENV__ at
    # macroexpansion time. Haven't figured out how to make use of that
    # information within a single function, so the caller will have to
    # adjust the result if the first part of the function is a module
    # alias.
  
  def decompose_call_alt(funcall) do
    case Macro.decompose_call(funcall) do
      {{:__aliases__, _, aliases},  fun_atom, args} -> 
        composed_alias =
          Enum.reduce(aliases, :Elixir, fn alias, acc ->
            Module.safe_concat(acc, alias)
          end)
        function_description = [{fun_atom, length(args)}]
        
        {:in_named_module, composed_alias, function_description, args}
        
      {fun_atom, args} ->
        function_description = [{fun_atom, length(args)}]
        {:in_calling_module, :use__MODULE__, function_description, args}
        
      _ ->
        raise """
        #{Macro.to_string(funcall)} does not look like a call to a function
        attached to a module.
        """
    end
  end

  def alias_to_module(the_alias, env) do 
    Keyword.get(env.aliases, the_alias, the_alias)
  end
end
