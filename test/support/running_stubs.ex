defmodule EctoTestDSL.RunningStubs do
  use Mockery
  alias MockeryExtras.Given
  alias EctoTestDSL.Run.RunningExample

  defmacro stub(kws) do
    for {key, val} <- kws do
      Given.expand(RunningExample, [{key, 1}], [:running], return: val)
    end
  end

  defmacro stub_history(kws) do
    for {key, val} <- kws do
      Given.expand(RunningExample, [step_value!: 2], [:running, key], return: val)
    end
  end
end
