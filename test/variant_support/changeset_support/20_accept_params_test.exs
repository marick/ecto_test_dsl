defmodule VariantSupport.Changeset.AcceptParamsTest do
  use TransformerTestSupport.Case
  alias T.VariantSupport.ChangesetSupport
  alias T.Run.RunningExample
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

    %RunningExample{example: example, history: [params: %{"age" => "1"}]}
    |> ChangesetSupport.accept_params
    |> assert_equal(:changeset_result)
  end
end
