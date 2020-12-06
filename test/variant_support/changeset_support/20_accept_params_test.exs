defmodule VariantSupport.Changeset.AcceptParamsTest do
  alias TransformerTestSupport, as: T
  use T.Case
  alias T.VariantSupport.ChangesetSupport
  alias T.RunningExample
  alias T.RunningExample.History
  alias Template.Dynamic


  defmodule Schema do
    defstruct age: nil
    
    def changeset(struct, attrs) do
      assert struct == struct(__MODULE__)
      assert attrs == %{"age" => "1"}
      :changeset_result
    end
  end

  defmodule Examples do
    use Template.EctoClassic.Insert
  end

  test "the only result" do
    example = 
      Dynamic.configure(Examples, Schema)
      |> Dynamic.example_in_workflow(:success,
          params: %{age: 1})
    running = 
      %RunningExample{example: example, history: History.trivial}
    assert ChangesetSupport.accept_params(running) == :changeset_result
  end

  @tag :skip
  test "should have a 'with previously case"
  
end
