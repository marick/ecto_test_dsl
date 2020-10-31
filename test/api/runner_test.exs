defmodule Api.RunnerTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport, as: T
  alias T.Build
  alias T.Runner
  alias T.Variants.EctoClassic
  alias Ecto.Changeset

  defmodule Schema do 
    use Ecto.Schema
    import Ecto.Changeset

    embedded_schema do
      field :age, :integer
    end

    def changeset(struct, params) do
      struct
      |> cast(params, [:age])
      |> validate_required([:age])
    end
  end

  defmodule Examples do
    use EctoClassic

    def create_test_data do 
      start(
        module_under_test: Schema,
        format: :phoenix
      ) |>
      
      category(                                         :success,
        ok: [params(age: 1)])
    end
  end

  test "stopping early after a step" do
    assert [make_changeset: made, example: _] = 
      Examples.Tester.example(:ok) |> Runner.run_steps(stop_after: :make_changeset)

    made
    |> assert_shape(%Changeset{})
  end
  
end

  
