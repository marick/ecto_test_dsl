defmodule Run.Steps.ChangesetFromParamsTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias T.Run.Steps
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
    use Template.PhoenixGranular.Insert
  end

  test "the only result" do
    example = 
      Dynamic.configure(Examples, Schema)
      |> Dynamic.example_in_workflow(:success,
          params: %{age: 1})

    %RunningExample{example: example, history: [params: %{"age" => "1"}]}
    |> Steps.Changeset.changeset_from_params
    |> assert_equal(:changeset_result)
  end
end
