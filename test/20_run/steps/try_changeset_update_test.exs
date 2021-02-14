defmodule Run.Steps.TryChangesetUpdateTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias Run.Steps.Ecto, as: Steps
  import T.RunningStubs

  defmodule Schema do
    use Ecto.Schema
    import Ecto.Changeset
    
    schema "bogus" do
      field :age, :integer
    end

    def update_changeset(struct, params) do
      struct
      |> cast(params, [:age])
    end
  end

  def a_changeset, do: Schema.update_changeset(%Schema{age: 23}, %{"age" => "24"})

  def updater(repo, changeset) do
    assert repo == Repo
    assert changeset == a_changeset()
    :update_return_value
  end

  test "try_changeset_update" do
    stub_history(changeset: a_changeset())
    stub(repo: Repo, update_with: &updater/2)
    
    actual = Steps.try_changeset_update(:running, :changeset)
    assert actual == :update_return_value
  end
end
