defmodule Variants.EctoClassic.ValidationErrorTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Variants.EctoClassic
  import FlowAssertions.Define.Tabular

  defmodule Schema do 
    use Ecto.Schema
    import Ecto.Changeset

    embedded_schema do
      field :date, :date
    end

    def changeset(struct, params) do
      struct
      |> cast(params, [:date])
      |> validate_required([:date])
    end
  end


  defp test_data(category_name, params, changeset_checks) do 
    TestBuild.one_category(category_name,
      [module_under_test: Schema,
       format: :phoenix],
      example: [params: params,
                changeset: changeset_checks])
  end

  setup do
    asserter = fn category_name, datestring, changeset_checks ->
      test_data = test_data(category_name, [date: datestring], changeset_checks)
      changeset = EctoClassic.validate_params(test_data, :example)
      EctoClassic.validation_assertions(changeset, test_data, :example)
      category_name  
    end
    [a: assertion_runners_for(asserter)]
  end

  @invalid_string "2001-01-0"
  @no_checks []
  test "auto_generated validity checks", %{a: a} do
    [:success,            @invalid_string, @no_checks]      |> a.fail.(~r/is invalid/)
    [:validation_failure, @invalid_string, @no_checks]      |> a.pass.()
  end


  @valid_string "2001-01-01"
  @valid_actual [change: [date: ~D[2001-01-01]]]
  @invalid_actual [change: [date: ~D[2111-11-11]]]
  test "checks applied when the params should be valid", %{a: a} do 
    [:success, @valid_string,   @valid_actual]   |> a.pass.()
    [:success, @valid_string,   @invalid_actual] |> a.fail.(~r/has the wrong value/)
    [:success, @invalid_string, @valid_actual]   |> a.fail.(~r/is invalid/)
  end
    
  test "checks applied when the params should be invalid", %{a: a} do
    [:validation_failure, @valid_string,   @valid_actual]   |> a.fail.(
       ~r/supposed to be invalid/)
    [:validation_failure, @valid_string,   @invalid_actual] |> a.fail.(
       ~r/supposed to be invalid/)
    [:validation_failure, @invalid_string, @invalid_actual] |> a.fail.(
       ~r/`:date` is missing/)
  end
end
