defmodule Run.Steps.PostCheckTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias T.Run.Steps
  import T.RunningStubs
  
  defmodule Schema do
  end

  defmodule Repo do
  end

  setup do 
    stub(name: :example)
    :ok
  end

  test "not present" do
    stub(postcheck: nil)
    assert Steps.postcheck(:running) == :uninteresting_result
  end

  test "runs assertion" do
    stub(postcheck: fn :running -> assert 1 == 2 end)

    assertion_fails(~r/Example `:example`: Postcheck assertion failed/,
      [message: ~r/Assertion with == failed/,
       left: 1,
       right: 2],
      fn -> 
        Steps.postcheck(:running)
      end)
  end
end
