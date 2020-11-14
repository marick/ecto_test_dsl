defmodule VariantSupport.Changeset.AcceptParamsTest do
  alias TransformerTestSupport, as: T
  use T.Case
  alias T.VariantSupport.ChangesetSupport
  alias T.RunningExample
  alias T.RunningExample.History

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

    running = 
      %RunningExample{example: example, history: History.trivial}
    assert ChangesetSupport.accept_params(running) == :changeset_result
  end

  @tag :skip
  test "should have a 'with setup case"
  
end
