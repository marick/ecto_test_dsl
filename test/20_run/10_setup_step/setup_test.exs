defmodule Neighborhood.CreateTest do
  use TransformerTestSupport.Drink.Me
  alias T.Variants.PhoenixClassic
  alias T.Run.Steps

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

    def named(name),
      do: %Schema{name: Test.Factory.unique(name), id: "#{name}_id"}
  end

  defmodule Examples do
    use PhoenixClassic.Insert

    def fake_insert(_ecto, changeset),
      do: {:ok, Schema.named(changeset.changes.name)}

    def make(name),
      do: {name, [params(name: to_string(name))]}
    def make(name, one_previously),
      do: {name, [params(name: to_string(name)), one_previously]}

    def create_test_data do 
      start(
        module_under_test: Schema,
        repo: Unused,
        insert_with: &fake_insert/2
      ) |>

      workflow(                                         :success, [
        make(:leaf),
        make(:leaf2),
        make(:dependent, previously(insert:  [leaf: __MODULE__])),
        make(:depth_3,   previously(insert:   :dependent)),

        make(:breadth_2, previously(insert:          [:leaf,   # one insert, two examples
                                                 :leaf2])), 
        make(:insert_then_insert, previously(insert: :depth_3, # two inserts
                                        insert: :leaf2)),

        make(:has_duplicates, previously(insert: :depth_3, insert: :dependent))
      ])
      end
  end

  defmodule ActualTests do
    use TransformerTestSupport.Case

    # Note: this won't necessarily prevent races if any other tests
    # use these names.
    def start_names_with_zero() do
      Examples.Tester.test_data.examples
      |> Keyword.keys
      |> Enum.map(&to_string/1)
      |> ExMachina.Sequence.reset
    end
      

    def setup_for(example_name) do
      start_names_with_zero()
      Examples.Tester.check_workflow(example_name)
      |> Keyword.get(:previously)
    end

    # Note: `setup_for` and `expect` are a bit tricksy. Each example is
    # supposed to only be created once. By resettting ExMachina.Sequence
    # before running the test and checking the actual result,
    # a duplicate creation will produce a different final name in the two.

    def expect(actual, names) do
      start_names_with_zero()
      
      expected = 
        names
        |> Enum.map(fn name ->
                      {een(name, Examples), Schema.named(to_string name)}
                    end)
        |> Map.new
      assert actual == expected
    end
    
    # ----------------------------------------------------------------------------

    test "insertions" do
      setup_for(:leaf)      |> expect([])  # no setup clause
      setup_for(:dependent) |> expect([:leaf]) # depends on one other value
      setup_for(:breadth_2) |> expect([:leaf, :leaf2])  # depends on two
      setup_for(:depth_3)   |> expect([:leaf, :dependent]) # recurses
      setup_for(:insert_then_insert) |> expect([:depth_3, :dependent, :leaf, :leaf2])
      setup_for(:has_duplicates)     |> expect([:depth_3, :dependent, :leaf])
    end
  end
end
