defmodule EctoTestDSL.RunningStubs do
  use Mockery
  use Given
  alias EctoTestDSL.Run.RunningExample

  defmacro stub(kws) do
    for {key, val} <- kws do
      Given.expand_given(RunningExample, [{key, 1}], [:running], val)
    end
  end

  defmacro stub_history(kws) do
    for {key, val} <- kws do
      Given.expand_given(RunningExample, [step_value!: 2], [:running, key], val)
    end
  end
end
