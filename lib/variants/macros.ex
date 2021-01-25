defmodule EctoTestDSL.Variants.Macros do

  defp one_step(step_name, step_module) do
    quote do
      def unquote(step_name)(running, rest_args) do
        args = [running | rest_args]
        apply(unquote(step_module), unquote(step_name), args)
      end
    end
  end

  defmacro defsteps(steps, from: step_module) do
    for name <- steps do
      one_step(name, step_module)
    end
  end


end
