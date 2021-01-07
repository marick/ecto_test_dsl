defmodule TransformerTestSupport.Mock do
  import Mockery

  @doc """
  given Module.function, [args...], do: return-value
  """

  defmacro given(modulename, args, do: body) do
    {{:., _, [module, fn_name]},
      _, _
    } = modulename

    fn_descriptor = [{fn_name, length(args)}]

    quote do
      mock(unquote(module), unquote(fn_descriptor), fn(unquote_splicing(args)) ->
        unquote(body)
      end)
    end
  end

  defmacro __using__(_) do
    quote do
      require Crit.Mock
      import Crit.Mock
    end
  end
end
