defmodule Run.Steps.ExistingIdsTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias T.Run.Steps
  import T.RunningStubs
  alias T.Variants.Common.DefaultFunctions
  
  defmodule Schema do
  end

  defmodule Repo do
    def all(_schema), do: :stub_me
  end

  test "right arguments are passed" do
    stub(
      repo: Repo,
      schema: Schema,
      existing_ids_with: fn ~M{repo, schema} ->
        assert repo == Repo
        assert schema == Schema
        [1, 3]
      end)

    assert Steps.existing_ids(:running) == [1, 3]
  end

  test "The default version" do
    given Repo.all(Schema), return: [%{id: 3}, %{id: 4}]

    context = %{repo: Repo, schema: Schema}

    assert DefaultFunctions.existing_ids(context) == [3, 4]
  end
end
