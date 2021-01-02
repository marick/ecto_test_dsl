defmodule VariantSupport.Changeset.ParamsTest do
  use TransformerTestSupport.Case
  alias T.VariantSupport.ChangesetSupport
  alias T.Run.RunningExample
  use T.Parse.All
  alias Ecto.Changeset

  defmodule Species do
    defstruct id: nil
  end

  defmodule SpeciesExamples do
    use Template.EctoClassic.Insert

    def create_test_data do 
      start(
        module_under_test: Species,
        repo: :irrelevant,
        changeset_with: fn _, _ -> %Changeset{valid?: true} end,
        insert_with: fn _, _ -> {:ok, %{id: 37373}} end
      ) |> 
      workflow(:success, bovine: [params()])
    end
  end
  

  defmodule Animal do
    defstruct age: nil, species_id: nil
  end

  defmodule Examples do
    use Template.EctoClassic.Insert

    def create_test_data do
      started(module_under_test: Animal)
      |> workflow(:success,
           bossie: [params(age: 1, species_id: id_of(bovine: SpeciesExamples))])
    end
  end

  test "params resolves dependencies" do
    Examples.Tester.params(:bossie)
    |> assert_equal(%{"age" => "1", "species_id" => "37373"})
  end
end
