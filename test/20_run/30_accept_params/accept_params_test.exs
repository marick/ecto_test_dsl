defmodule Run.AcceptParamsTest do
  use TransformerTestSupport.Case
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
    use Template.EctoClassic.Insert
  end

  test "the only result" do
    example = 
      Dynamic.configure(Examples, Schema)
      |> Dynamic.example_in_workflow(:success,
          params: %{age: 1})

    %RunningExample{example: example, history: [params: %{"age" => "1"}]}
    |> Steps.accept_params
    |> assert_equal(:changeset_result)
  end
end
