defmodule Variants.EctoClassic.CheckEverythingTest do
  use TransformerTestSupport.Case
  import FlowAssertions.AssertionA
  use TransformerTestSupport.Variants.EctoClassic

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

  defmodule Variant do
    use TransformerTestSupport.Variants.EctoClassic
    
    def create_test_data do
      start(
        module_under_test: Schema,
        format: :phoenix
      ) |>

      category(:success,
        example: [
          params(date: "2001-02-0")
        ])
    end
  end

  test "happens if changeset is valid" do
    # This demonstrates the assertion was called.
    assertion_fails(~R/changeset is invalid/,
      fn ->
        Variant.Tester.validate(:example)
      end)
  end
end
