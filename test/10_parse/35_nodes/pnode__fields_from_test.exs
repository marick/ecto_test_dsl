defmodule EctoTestDSL.Pnode.FieldsFromTest do
  use EctoTestDSL.Case
  use T.Drink.AndParse
  use T.Parse.Exports

  setup do
    BuildState.put(%{examples_module: Examples})
    :ok
  end

  describe "parsing" do
    setup do
      run = fn een_or_name, opts ->
        Pnode.FieldsFrom.parse(een_or_name, opts)
      end

      [run: run]
    end

    test "een and id_of", ~M{run} do
      given_een = een(example: Creator)
      actual = run.(een(example: Creator), 
        except: [species_id: id_of(species: Second)])

      assert Pnode.EENable.eens(actual) == [given_een, een(species: Second)]
      assert_fields(actual,
        reference_een: given_een,
        opts: [except: [species_id: id_of(species: Second)]])
    end

    test "een alone", ~M{run} do
      given_een = een(example: Creator)
      actual = run.(given_een, [])

      assert Pnode.EENable.eens(actual) == [given_een]
      assert_fields(actual,
        reference_een: given_een,
        opts: [])
    end
    
    test "a name rather than an een alone", ~M{run} do
      opts = [except: [species_id: id_of(species: Second)]]
      actual = run.(:example, opts)

      assert Pnode.EENable.eens(actual) == [een(example: Examples),
                                            een(species: Second)]
      assert_fields(actual,
        reference_een: een(example: Examples),
        opts: [except: [species_id: id_of(species: Second)]])
    end
  end

  test "export" do
    input = %Pnode.FieldsFrom{reference_een: "...some een...",
                              opts: "...some opts..."}

    expected = %Rnode.FieldsFrom{een: "...some een...", opts: "...some opts..."}

    assert Pnode.Exportable.export(input) == expected
  end
end  
