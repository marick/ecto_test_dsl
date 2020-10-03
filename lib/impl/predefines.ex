defmodule TransformerTestSupport.Impl.Predefines do
  @moduledoc """
  """

  defmacro __using__(_) do
    quote do
      alias TransformerTestSupport.Impl.Build
      alias TransformerTestSupport.Impl.Get
      alias TransformerTestSupport.Impl.Validations

      # ----- Building test data ---------------------------------------------------

      @name_of_test_data __MODULE__

      def start(global_data),
        do: Build.start(@name_of_test_data, global_data)

      def test_data(), do: Get.test_data(@name_of_test_data)

      def category(category_name, examples),
          do: Build.category(@name_of_test_data, category_name, examples)

      def params(opts), do: {:params, Enum.into(opts, %{})}
      def changeset(opts), do: {:changeset, opts}

      # ----- Using test data ------------------------------------------------------

      def get_params(example_name),
        do: Get.get_params(@name_of_test_data, example_name)

      def validate(example_name),
        do: Validations.validate(@name_of_test_data, example_name)
    end
  end
end
