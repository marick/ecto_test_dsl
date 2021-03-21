defmodule Run.Steps.FieldsFromTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias Run.Steps
  use Mockery
  import T.RunningStubs
  import T.Parse.InternalFunctions
  alias T.Run.Rnode

  setup do
    stub(name: :example, neighborhood: %{})
    stub(result_fields: %{}, usually_ignore: [])
    :ok
  end

  defp run([{:after, neighborhood},
            {:compare, new_struct},
            {:against, reference_struct} | adjustments]) do
    stub(neighborhood:
      Map.put(neighborhood, een(:reference_struct), reference_struct))
    
    instructions = Rnode.FieldsFrom.new(een(:reference_struct), adjustments)
    stub(result_matches: instructions)

    stub_history(new_struct: new_struct)
    Steps.check_results(:running, :new_struct)
  end

  defp run([{:compare, new_struct}, {:against, reference_struct} | adjustments]) do
    run([{:after, %{}}, {:compare, new_struct},
         {:against, reference_struct} | adjustments])
  end
  

  defp pass(setup), do: assert run(setup) == :uninteresting_result

  describe "result_matches basics" do
    test "just an een" do
      [compare: %{a: 5},
       against: %{a: 5}] |> pass()

      bad_field = [compare: %{a: 5},
                   against: %{a: 4}]
      
      assertion_fails(~r/Example `:example`/,
        [message: ~r/Assertion with == failed/,
         left:  %{a: 5},
         right: %{a: 4}],
        fn ->
          run(bad_field)
        end)

      extra_field = [compare: %{a: 5, extra: 1},
                     against: %{a: 5          }]
      
      assertion_fails(~r/Example `:example`/,
        [message: ~r/Assertion with == failed/,
         left:  %{a: 5, extra: 1},
         right: %{a: 5}],
        fn ->
          run(extra_field)
        end)
    end
    
    test "`ignoring` option" do
      [compare: %{a: 5,     lock_value: 58},
       against: %{a: 5                    },
                 ignoring: [:lock_value]] |> pass()
    end

    test "`except` option" do
      [compare: %{a: 5,  special: "new"},
       against: %{a: 5,  special: "old"},
                except: [special: "new"]] |> pass()
    end

    test "`except` fills in foreign keys" do
      [after: %{een(:bovine) => Neighborhood.Value.inserted(%{id: 12})},

       compare: %{a: 5, species_id: 12        },
       against: %{a: 5, species_id: "replaced"},
               except: [species_id: id_of(:bovine)]] |> pass()
    end
  end

  describe "global 'usually_ignore'" do
    test "has an effect" do
      stub(usually_ignore: [:lock_value])

      [compare: %{a: 5,      lock_value: 9},
       against: %{a: 5,      lock_value: 8}] |> pass()
    end

    test "merges `:usually_ignore` with a specific `:ignoring`" do
      stub(usually_ignore: [:lock_value])

      [compare:  %{a: 8,     lock_value: 9},
       against:  %{a: 5,     lock_value: 8},
       ignoring: [:a]] |> pass()
    end

    test "`comparing` cancels out the effects of the global `usually_ignore`" do
      stub(usually_ignore: [:a])

             # although lock_value is wrong, it's not listed in `comparing`
      [compare: %{a: 5, lock_value: 9},
       against: %{a: 5, lock_value: 8},
       comparing: [:a]] |> pass()
    end

    test "if a value is explicitly `except`ed, that overrides `usually_ignore`" do
      stub(usually_ignore: [:a])

      run_args = [compare: %{a: 5},
                  against: %{a: 5},
                  except: [a: "wrong"]]

      assertion_fails(~r/Example `:example`/,
        [message: ~r/`:a` has the wrong value/,
         left:  5,
         right: "wrong"],
        fn ->
          run(run_args)
        end)
    end


    test "... but other values ae still ignored" do
      stub(usually_ignore: [:a, :lock_value])

      run_args = [compare: %{a: "right",       lock_value: 22},
                  against: %{a: 5, lock_value: 10},
                  except: [a: "right"]]
      pass(run_args)
    end      
  end

  describe "both `fields` and `result_matches` can be used" do
    setup do 
      stub(result_fields: [a: "right"])
      stub(result_matches: Rnode.FieldsFrom.new(een(:reference_struct), [comparing: [:b]]))
      :ok
    end


    test "that `fields` can fail" do 
      stub(neighborhood: %{een(:reference_struct) => %{a: "right", b: "right"}})
      stub_history(new_struct:            %{a: "wrong", b: "right"})

    assertion_fails(~r/Field `:a` has the wrong value/,
      [left:  "wrong",
       right: "right"],
        fn ->
          Steps.check_results(:running, :new_struct)
        end)
    end

    test "that `result_matches` can fail" do 
      stub(neighborhood: %{een(:reference_struct) => %{a: "right", b: "right"}})
      stub_history(new_struct:            %{a: "right", b: "wrong"})

      assertion_fails(~r/Assertion with == failed/,
      [left:  %{b: "wrong"},
       right: %{b: "right"}],
        fn ->
          Steps.check_results(:running, :new_struct)
        end)
    end
  end
end
