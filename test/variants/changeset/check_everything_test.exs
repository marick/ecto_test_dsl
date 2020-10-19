defmodule Variants.EctoClassic.CheckEverythingTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Variants.EctoClassic
  import FlowAssertions.AssertionA
  alias TransformerTestSupport.Build

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

  test "happens if changeset is valid" do
    test_data = %{
      module_under_test: Schema,
      format: :phoenix,
      examples: [
        example: %{params: %{date: "2001-02-0"},
                   changeset: [:valid]}  # Provoke an assertion failurexs
      ]
    } |> Build.propagate_metadata
    
    # This demonstrates the assertion was called.
    assertion_fails(~R/changeset is invalid/,
      fn ->
        EctoClassic.check_everything(test_data, :example)
      end)
  end
end
