defmodule Variants.PhoenixClassic.Insert.WithOverridesTest do
  use TransformerTestSupport.Case
  alias Ecto.Changeset
  
  defmodule Examples do
    use T.Variants.PhoenixClassic.Insert
    
    def changeset_maker(SomeSchema, _params) do
      ChangesetX.valid_changeset(changes: %{field: "value"})
    end      
    
    def insertion_doer(SomeRepo, %Changeset{changes: %{field: "value"}}) do
      {:ok, "insertion return value"}
    end

    def create_test_data do
      start(
        module_under_test: SomeSchema,
        repo: SomeRepo,
        changeset_with: &changeset_maker/2,      # <<<<<<<<<<<<<
        insert_with: &insertion_doer/2           # <<<<<<<<<<<<<
      ) |>

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
