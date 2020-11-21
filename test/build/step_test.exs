defmodule Build.StepTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport, as: T
  alias T.Build
  alias T.Variants.EctoClassic

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

  defmodule ChosenResultStep do
    use EctoClassic

    def fake_validate(_changeset), do: "substitute result"

    def create_test_data() do
      new_step = step(&fake_validate/1, :example) # instead of changeset

      start_with_variant(EctoClassic, module_under_test: Schema)
      |> replace_steps(check_validation_changeset: new_step)
      |> workflow(:validation_success, ok: [params(age: 1)])
    end
  end
  
  test "steps can pick the value to use" do
    actual = ChosenResultStep.Tester.check_workflow(:ok)
    assert Keyword.get(actual, :check_validation_changeset) == "substitute result"
  end
end
