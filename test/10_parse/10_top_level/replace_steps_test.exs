defmodule Parse.TopLevel.ReplaceStepTest do
  use TransformerTestSupport.Case

  defmodule Schema do 
    use Ecto.Schema
    import Ecto.Changeset

    embedded_schema do
      field :age, :integer
    end

    def changeset(struct, params) do
      struct
      |> cast(params, [:age])
    end
  end

  defmodule Examples do
    use Template.EctoClassic.Insert

    def fake_validate(_changeset), do: "substitute result"

    def create_test_data() do
      new_step = step(&fake_validate/1, :example) # instead of changeset

      started(module_under_test: Schema)
      |> replace_steps(check_validation_changeset: new_step)
      |> workflow(:validation_success, ok: [params(age: 1)])
    end
  end
  
  test "replace_steps works" do
    actual = Examples.Tester.check_workflow(:ok)
    assert Keyword.get(actual, :check_validation_changeset) == "substitute result"
  end
end
