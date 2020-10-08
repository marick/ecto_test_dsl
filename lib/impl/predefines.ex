defmodule TransformerTestSupport.Impl.Predefines do
  @moduledoc """
  """

  defmacro __using__(_) do
    quote do
      alias TransformerTestSupport.Impl.{Build,Get,Validations,Like}

      # ----- Building test data ---------------------------------------------------

      @name_of_test_data __MODULE__

      def start(global_data),
        do: Build.start(@name_of_test_data, global_data)

      @doc """
      Potentially useful for debugging
      """
      def test_data(), do: Get.test_data(@name_of_test_data)

      @doc """
      Potentially useful for debugging
      """
      def example(name), do: Keyword.get(test_data().examples, name)

      def category(category_name, examples),
          do: Build.category(@name_of_test_data, category_name, examples)

      def params(opts),
        do: {:params, Enum.into(opts, %{})}

      def params_like(example_name, opts),
        do: {:params, Build.make__params_like(example_name, opts)}
      def params_like(example_name), 
        do: params_like(example_name, except: [])

      def changeset(opts), do: {:changeset, opts}

      # ----- Using test data ------------------------------------------------------

      def validate(example_name),
        do: Validations.validate(@name_of_test_data, example_name)

      def check_everything do
        for {example_name, _} <- test_data().examples,
          do: check_everything(example_name)
      end

      def check_everything(example_name) do 
        data = test_data()
        data.variant.check_everything(data, example_name)
      end


      defmodule Tester do
        @name_of_test_data Module.split(__MODULE__) |> Enum.drop(-1) |> Module.safe_concat

        def test_data(), do: Get.test_data(@name_of_test_data)
        
        def example(name), do: Keyword.get(test_data().examples, name)

        def params(example_name),
          do: Get.params(@name_of_test_data, example_name)
        
        def validate(example_name),
          do: Validations.validate(@name_of_test_data, example_name)
        
        def check_everything do
          for {example_name, _} <- test_data().examples,
            do: check_everything(example_name)
        end
        
        def check_everything(example_name) do 
          data = test_data()
          data.variant.check_everything(data, example_name)
        end
        
      end
    end
  end
end
