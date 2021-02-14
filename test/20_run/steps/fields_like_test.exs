defmodule Run.Steps.FieldsLikeTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias Run.Steps
  use Mockery
  import T.RunningStubs
  import T.Parse.InternalFunctions
  alias T.Run.Rnode

  setup do
    stub(name: :example, neighborhood: %{})
    stub(field_checks: %{})
    :ok
  end

  defp run(~M{under_test, opts}) do 
    stub_history(updated_value: under_test)
    stub(fields_like: Rnode.FieldsLike.new(een(:inserted), opts))
    Steps.field_checks(:running, :updated_value)
  end

  defp pass(setup), do: assert run(setup) == :uninteresting_result

  describe "fields_like" do
    test "just an een: pass" do
      stub(neighborhood: %{een(:inserted) => %{a: 5}})
      %{under_test:                          %{a: 5}, opts: []} |> pass()
    end

    test "just an een: fail" do
      stub(neighborhood: %{een(:inserted) => %{a: 4}})
      input = %{under_test:                  %{a: 5}, opts: []}

      assertion_fails(~r/Example `:example`/,
        [message: ~r/Assertion with == failed/,
         left:  %{a: 5},
         right: %{a: 4}],
        fn ->
          run(input)
        end)
    end

    test "just an een: extra fields" do
      stub(neighborhood: %{een(:inserted) => %{a: 5}})
      input = %{under_test:                  %{a: 5, b: 4}, opts: []}

      assertion_fails(~r/Example `:example`/,
        [message: ~r/Assertion with == failed/,
         left:  %{a: 5, b: 4},
         right: %{a: 5}],
        fn ->
          run(input)
        end)
    end
    
    test "`ignoring` works" do
      stub(neighborhood: %{een(:inserted) => %{a: 5}})
      input = %{
        under_test:                          %{a: 5, lock_value: 58},
        opts:                           [ignoring: [:lock_value]]
      }

      input |> pass()
    end

    test "`except` works" do
      stub(neighborhood: %{een(:inserted) => %{a: 5, special: "old"}})

      input = %{
                           under_test:       %{a: 5, special: "new"},
        opts:                              [except: [special: "new"]]
      }

      input |> pass()
    end
    
    test "`except` fills in foreign keys" do
      stub(neighborhood: %{een(:inserted) => %{a: 5, species_id: 12},
                           een(:bovine)   => %{              id: 12}})

      input = %{
                            under_test:      %{a: 5, species_id: 12},
                                     opts: [except: [species_id: id_of(:bovine)]]
      }

      input |> pass()
    end
  end

  describe "both `fields` and `fields_like` can be used" do

    setup do 
      stub(field_checks: [a: "right"])
      stub(fields_like: Rnode.FieldsLike.new(een(:inserted), [comparing: [:b]]))
      :ok
    end


    test "that `fields` can fail" do 
      stub(neighborhood: %{een(:inserted) => %{a: "right", b: "right"}})
      stub_history(updated_value:            %{a: "wrong", b: "right"})

    assertion_fails(~r/Field `:a` has the wrong value/,
      [left:  "wrong",
       right: "right"],
        fn ->
          Steps.field_checks(:running, :updated_value)
        end)
    end

    test "that `fields_like` can fail" do 
      stub(neighborhood: %{een(:inserted) => %{a: "right", b: "right"}})
      stub_history(updated_value:            %{a: "right", b: "wrong"})

      assertion_fails(~r/Assertion with == failed/,
      [left:  %{b: "wrong"},
       right: %{b: "right"}],
        fn ->
          Steps.field_checks(:running, :updated_value)
        end)
    end
  end
end
