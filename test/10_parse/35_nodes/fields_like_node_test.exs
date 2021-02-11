defmodule EctoTestDSL.Parse.Node.FieldsLikeNodeTest do
  use EctoTestDSL.Case
  alias T.Parse.Node
  import T.Parse.InternalFunctions

  describe "ensuring eens" do
    setup do
      run = fn een_or_name, default_module, opts ->
        Node.FieldsLike.parse(een_or_name, opts)
        |> Node.EENable.ensure_eens(default_module)
      end

      [run: run]
    end

    test "een and id_of", ~M{run} do
      given_een = een(example: Creator)
      actual = run.(een(example: Creator), "unused_default_module",
        except: [species_id: id_of(species: Second)])

      assert Node.EENable.eens(actual) == [given_een, een(species: Second)]
      assert actual.with_ensured_eens == %{reference_een: given_een,
                                           opts: actual.parsed.opts}
    end

    test "een alone", ~M{run} do
      given_een = een(example: Creator)
      actual = run.(given_een, "unused_default_module", [])

      assert Node.EENable.eens(actual) == [given_een]
      assert actual.with_ensured_eens == %{reference_een: given_een,
                                           opts: actual.parsed.opts}
    end
    
    test "a name rather than an een alone", ~M{run} do
      opts = [except: [species_id: id_of(species: Second)]]
      actual = run.(:example, SomeModule, opts)

      assert Node.EENable.eens(actual) == [een(example: SomeModule),
                                           een(species: Second)]
      assert actual.with_ensured_eens == %{reference_een: een(example: SomeModule),
                                           opts: opts}
    end
  end

  @tag :skip
  test "export" do
    # %Node.FieldsLike{with_ensured_eens: %{a: 1, b: id_of(:fred)}}
    # |> Node.Exportable.export
    # |> assert_equal(%{a: 1, b: id_of(:fred)})
  end
end  
