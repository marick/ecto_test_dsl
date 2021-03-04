defmodule Run.Steps.ChangesetForUpdateTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias T.Run.Steps
  alias Template.Dynamic


  defmodule Schema do
    defstruct age: nil
    
    def changeset(struct, attrs) do
      assert struct.age == 33
      assert attrs == %{"age" => "1"}
      :changeset_result
    end
  end

  defmodule Examples do
    use Template.PhoenixGranular.Update
  end

  IO.puts "NEXT"
  @tag :skip
  test "the only result" do
    example = 
      Dynamic.configure(Examples, Schema)
      |> Dynamic.example_in_workflow(:success,
          params: %{age: 1})

    %RunningExample{example: example,
                    history: [
                      struct_for_update: %Schema{age: 33},
                      params: %{"age" => "1"}
                    ]}
    |> Steps.changeset_for_update(:struct_for_update)
    |> assert_equal(:changeset_result)
  end
end
