defmodule Run.Steps.ChangesetFromParamsTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias T.Run.Steps
  import T.RunningStubs

  defmodule Schema do
    defstruct age: nil
  end

  defmodule Api do
  end

  test "the only result" do
    expected_api_module = Api
    expected_schema = Schema
    expected_params = %{"age" => "1"}

    stub(
      api_module: expected_api_module,
      schema: expected_schema,
      formatted_params: expected_params,
      changeset_with: fn ~M{schema, api_module, formatted_params} ->
        assert api_module == expected_api_module
        assert schema == expected_schema
        assert expected_params == formatted_params
        :changeset_result
      end)

    Steps.changeset_from_params(:running)
    |> assert_equal(:changeset_result)
  end
end
