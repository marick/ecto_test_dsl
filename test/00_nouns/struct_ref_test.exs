defmodule Nouns.StructRefTest do
  use EctoTestDSL.Case
  alias T.Nouns.RefHolder
  use T.Parse.Exports


  @een een(example_name: Examples)
  @other_een een(:a)
  @other_ref id_of(:a)

  def create(opts), do: StructRef.new(@een, opts)

  test "creation" do
    create([])
    |> assert_fields(reference_een: @een,
                     eens: [@een],
                     except: %{}, ignoring: [], only: [])

    create([except: [a_id: @other_ref]])
    |> assert_fields(reference_een: @een,
                     eens: [@een, @other_een],
                     except: %{a_id: @other_ref},
                     ignoring: [],
                     only: [])

    create([except: [a_id: @other_ref], ignoring: [:m]])
    |> assert_fields(reference_een: @een,
                     eens: [@een, @other_een],
                     except: %{a_id: @other_ref},
                     ignoring: [:m],
                     only: [])

    create([only: [:m]])
    |> assert_fields(reference_een: @een,
                     eens: [@een],
                     except: %{},
                     ignoring: [],
                     only: [:m])

    assertion_fails(~r/both `ignoring:` and `only:`/,
      fn ->
        create([only: [:m], ignoring: [:m]])
      end)
  end

  @neighborhood %{
    @een => Neighborhood.Value.params(%{a: 5, other_id: "start"}),
    @other_een => Neighborhood.Value.inserted(%{id: "override"})
  }

  defp deref(opts), do: create(opts) |> RefHolder.dereference(in: @neighborhood)

  describe "dereference" do
    test "simple case" do
      deref([])
      |> assert_equal(%{a: 5, other_id: "start"})
    end

    test "with except" do
      deref(except: [other_id: @other_ref])
      |> assert_equal(%{a: 5, other_id: "override"})
    end

    test "ignoring" do
      deref(ignoring: [:a])
      |> assert_equal(%{other_id: "start"})
    end
    
    test "only" do
      deref(only: [:other_id])
      |> assert_equal(%{other_id: "start"})
    end
  end
end 
