defmodule Nouns.ExampleTest do
  use EctoTestDSL.Case
  alias T.Nouns.Example

  test "what to do with a request to run" do
    pass = fn [context: context, example: example_is], expected ->
      assert Example.run_decision(%{run: example_is}, [run: context]) == expected
    end
    
    [context: :automatic_only, example: :nil] |> pass.(:run)
    [context: :for_value,      example: :nil] |> pass.(:run)
    
    [context: :automatic_only, example: :for_value] |> pass.(:skip_because_only_for_value)
    [context: :for_value,      example: :for_value] |> pass.(:run)
    
    [context: :automatic_only, example: :skip] |> pass.(:user_skip)

    assertion_fails(~r/You are running `:the_example` for its value/,
      fn -> 
        %{metadata: %{name: :the_example},  run: :skip}
        |> Example.run_decision([              run: :for_value])
      end)
  end
end 
