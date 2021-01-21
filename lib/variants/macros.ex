defmodule TransformerTestSupport.Variants.Macros do

  defp one_step({step_name, arg_suffix}, step_module) do
    quote do
      def unquote(step_name)(running) do
        args = [running | unquote(arg_suffix)]
        apply(unquote(step_module), unquote(step_name), args)
      end
    end
  end

  defp one_step(step_name, step_module),
    do: one_step({step_name, []}, step_module)

  defmacro defsteps(steps, from: step_module) do
    for namelike <- steps do
      one_step(namelike, step_module)
    end
  end
end
