defmodule TransformerTestSupport.Impl.Validations do
  # import FlowAssertions.Define.{Defchain,BodyParts}
  # import ExUnit.Assertions
  use FlowAssertions.Ecto
  alias TransformerTestSupport.Impl.Get
  

  @moduledoc """
  """

  def validate(test_data_module, example_name) when is_atom(test_data_module),
    do: validate_and_check(Get.test_data(test_data_module), example_name)

  def validation_result(test_data, example_name) do
    apply_variant(test_data, :validate_params, [test_data, example_name])
  end

  def validate_and_check(test_data, example_name) do
    example = Get.example(test_data, example_name)

    result = validation_result(test_data, example_name)
    apply_variant(test_data, :validation_assertions, [result, example_name, example])
  end

  defp apply_variant(test_data, function_name, args) do
    module = test_data.__sources[function_name]
    apply module, function_name, args
  end
end
