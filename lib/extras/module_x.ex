defmodule EctoTestDSL.ModuleX do
  # This software is public domain, covered by the UnLicense.
  
  @moduledoc """
  Utilities for defining functions that get map/struct/keyword values up to
  three levels of nesting. They're handy when you want to hide a complex
  structure behind an interface.

  Examples: 
      all = %{
        top1: 1,
        top2: 1.2,
        down: %{
          lower: 2,
          down: %{
            lowest: 3
          }
        }
      }

      getters([:top1, :top2])
      # defines top1/1, top2/1, so that
      # 
      # top1(all) => 1
      # top2(all) => 2

      # Three levels of nesting is allowed.

      getters(:down, :down, [:lowest])
      # lowest(all) => 3

  When defined like the above, a `KeyError` will be raised if any key
  is missing.

  Default values can be given:
    
      getters(:down, [lower: "some default"])

      # lower(%{down: %{}}) => "some default"

  Only the last step in the path may be missing. Applying `lower` to `%{}`
  would result in a key error.

  A variant, `private_getters`, will define the getters with `defp` instead
  of `def`.

  The generated functions will work with any combination of maps, structures, or
  keywords. So, for example, the following works:

      getters :history, [:params, :changeset]
    
      # changeset(%{history: [changeset: "..."]}) => "..."

  """

  defmodule Util do
    def module_for(%{}), do: Map
    def module_for([_car|_cdr]), do: Keyword
    
    def get_leaf(so_far, [namelike]) do
      case namelike do
        {name, default} ->
          module_for(so_far).get(so_far, name, default)
        name ->
          module_for(so_far).fetch!(so_far, name)
      end
    end

    def get_leaf(so_far, [name | rest]),
      do: module_for(so_far).fetch!(so_far, name) |> get_leaf(rest)

    def defx(def_kind, namelike, path) do
      true_name =
        case namelike do
          {name, _} -> name
          name -> name
        end
      
      quote do
        unquote(def_kind)(unquote(true_name)(maplike),
          do: Util.get_leaf(maplike, unquote(path)))
      end
    end
  end
    
  alias EctoTestDSL.ModuleX.Util

  # ---------GETTERS----------------------------------------------------------

  defmacro getters(names) when is_list(names) do
    for name <- names, do: Util.defx(:def, name, [name])
  end

  defmacro getters(top_level, names) when is_list(names) do
    for name <- names, do: Util.defx(:def, name, [top_level, name])
  end

  defmacro getters(top_level, next_level, names) when is_list(names) do
    for name <- names, do: Util.defx(:def, name, [top_level, next_level, name])
  end

  # ---------PRIVATE_GETTERS----------------------------------------------------------
  
  defmacro private_getters(names) when is_list(names) do
    for name <- names, do: Util.defx(:defp, name, [name])
  end

  defmacro private_getters(top_level, names) when is_list(names) do
    for name <- names, do: Util.defx(:defp, name, [top_level, name])
  end

  defmacro private_getters(top_level, next_level, names) when is_list(names) do
    for name <- names, do: Util.defx(:defp, name, [top_level, next_level, name])
  end

  # ----------------------------------------------------------------------------

  defmacro publicize(new_name, renames: old_name) do
    quote do
      def unquote(new_name)(maplike), do: unquote(old_name)(maplike)
    end
  end
end
