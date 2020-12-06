defmodule TransformerTestSupport.RunningExampleTest do
  alias TransformerTestSupport, as: T
  alias T.Build
  alias T.RunningExample
  alias T.Variants.EctoClassic
  alias Ecto.Changeset

  defmodule Schema do 
    use Ecto.Schema
    import Ecto.Changeset

    embedded_schema do
      field :name, :string
    end

    def changeset(struct, params) do
      struct
      |> cast(params, [:name])
      |> validate_required([:name])
    end
  end

  defmodule Examples do
    use EctoClassic.Insert

    def fake_insert(changeset),
      do: {:ok, "created `#{changeset.changes.name}`"}

    def create_test_data do 
      start(
        module_under_test: Schema,
        repo: :unused
      ) |>
      
      replace_steps(insert_changeset: step(&fake_insert/1, :make_changeset)) |>
      
      workflow(                                         :success,
        young: [params(name: "young")],
        dependent: [params(name: "dependent"), previously(insert: :young)],
        two_level: [params(name: "dependent"), previously(insert: :dependent)]
      )
    end
  end

  defmodule Tests do
    use TransformerTestSupport.Case

    test "stopping early after a step" do
      assert [make_changeset: made, previously: %{}, previously: %{}, example: _] = 
        Examples.Tester.example(:young) |> RunningExample.run(stop_after: :make_changeset)
      
      made
      |> assert_shape(%Changeset{})
    end

    @presupplied "presupplied, not created"

    test "A starting previously-state can be passed in" do
      expect = fn example_name, expected ->
        actual =  
          Examples.Tester.example(example_name)
          |> RunningExample.run(previously:
                %{{:young, Examples} => "presupplied, not created"})
        assert Keyword.get(actual, :previously) == expected
      end

      :dependent |> expect.(%{{:young, Examples} => @presupplied})
      # There is a recursive call
      :two_level |> expect.(%{
            {:young, Examples} => @presupplied,
            {:dependent, Examples} => "created `dependent`"})
    end
  end
end

  
