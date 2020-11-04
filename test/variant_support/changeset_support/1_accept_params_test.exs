defmodule VariantSupport.Changeset.AcceptParamsTest do
  use TransformerTestSupport.Case
  # import FlowAssertions.Define.Tabular
  alias TransformerTestSupport.VariantSupport.ChangesetSupport
  # alias TransformerTestSupport.SmartGet

  defstruct age: nil

  def changeset(struct, attrs) do
    assert struct == struct(__MODULE__)
    assert attrs == %{"age" => "1"}
    :changeset_result
  end
    
  

  test "the only result" do
    example = %{params: %{age: 1},
                metadata: %{module_under_test: __MODULE__,
                            format: :phoenix}}

    assert ChangesetSupport.accept_params(example) == :changeset_result
  end
  
end
