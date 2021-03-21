defmodule Variants.PhoenixGranular.WithOverridesTest do
  use EctoTestDSL.Case
  alias Ecto.Changeset
  
  defmodule Examples do
    use T.Variants.PhoenixGranular.Insert
    
    def changeset_maker(Api, _params) do
      ChangesetX.valid_changeset(changes: %{field: "value"})
    end

    @repo "no database transactions are done in this test"
    
    def insertion_doer(@repo, %Changeset{changes: %{field: "value"}}) do
      {:ok, "insertion return value"}
    end

    def create_test_data do
      start(
        api_module: Api,
        repo: @repo,
        changeset_with: &changeset_maker/2,      # <<<<<<<<<<<<<
        insert_with: &insertion_doer/2           # <<<<<<<<<<<<<
      )

      workflow(:success,
        example: [params(irrelevant_params: true)]
      )
    end
  end

  test "has an effect on changeset creation" do
    Examples.Tester.validation_changeset(:example)
    |> assert_change(field: "value")
  end

  test "has an effect on insertion" do
    Examples.Tester.inserted(:example)
    |> assert_equal("insertion return value")
  end  
end
