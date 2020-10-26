defmodule TransformerTestSupport.Variants.EctoClassic do
  alias TransformerTestSupport.Build
  use TransformerTestSupport.VariantSupport.Changeset


  def start(opts), do: Build.start_with_variant(__MODULE__, opts)

  # ------------------- Hook functions -----------------------------------------

  def run_start_hook(top_level) do
    sources = %{
      accept_params: __MODULE__,
      check_validation_changeset: __MODULE__,
    }

    Map.merge(top_level, %{__sources: sources})
  end

  @categories [:success, :validation_failure]

  def assert_category_hook(_, category) do
    elaborate_assert(
      category in @categories,
      "The EctoClassic variant only allows these categories: #{inspect @categories}",
      left: category
    )
  end
  
  # ----------------------------------------------------------------------------


  defmacro __using__(_) do
    quote do
      use TransformerTestSupport.Predefines
      alias TransformerTestSupport.Variants.EctoClassic

      def start(opts), do: EctoClassic.start(opts)
    end
  end
end
