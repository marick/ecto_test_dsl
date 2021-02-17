defmodule EctoTestDSL.Parse.Pnode.ParamsFromRepoTest do
  use EctoTestDSL.Case
  alias T.Parse.Pnode

  describe "creation" do
    test "normal" do
      Pnode.ParamsFromRepo.parse(een(:name), [except: [a: 1]])
      |> assert_fields(parsed: %{een: een(:name), except: [a: 1]})
    end
    
    test "an een is required" do
      assertion_fails(~r/Perhaps you meant `een\(name: SomeExamples\)`/,
        [left: :name], fn -> 
          Pnode.ParamsFromRepo.parse(:name, [except: [a: 1]])
        end)
    end

    test "een is *really* wrong" do
      assertion_fails(~r/Perhaps you meant `een\(some_name: SomeExamples\)`/,
        [left: "name"], fn -> 
          Pnode.ParamsFromRepo.parse("name", [except: [a: 1]])
        end)
    end

    test "bad options" do
      assertion_fails(~r/`params_from_repo`'s second argument must be `except: <keyword_list>`/,
        [left: [excep: [a: 1]]], fn -> 
          Pnode.ParamsFromRepo.parse("name", [excep: [a: 1]])
        end)
    end

    test "no option works too" do
      {:params, actual} = Parse.ExampleFunctions.params_from_repo(een(:name))
      expected = Pnode.ParamsFromRepo.parse(een(:name), except: [])
      assert actual == expected
    end
  end

  describe "ensuring eens" do
    # setup do
    #   run = fn een_or_name, default_module, opts ->
    #     Pnode.FieldsLike.parse(een_or_name, opts)
    #     |> Pnode.EENable.ensure_eens(default_module)
    #   end

    #   [run: run]
    # end

    # test "een and id_of", ~M{run} do
    #   given_een = een(example: Creator)
    #   actual = run.(een(example: Creator), "unused_default_module",
    #     except: [species_id: id_of(species: Second)])

    #   assert Pnode.EENable.eens(actual) == [given_een, een(species: Second)]
    #   assert actual.with_ensured_eens == %{reference_een: given_een,
    #                                        opts: actual.parsed.opts}
    # end

    # test "een alone", ~M{run} do
    #   given_een = een(example: Creator)
    #   actual = run.(given_een, "unused_default_module", [])

    #   assert Pnode.EENable.eens(actual) == [given_een]
    #   assert actual.with_ensured_eens == %{reference_een: given_een,
    #                                        opts: actual.parsed.opts}
    # end
    
    # test "a name rather than an een alone", ~M{run} do
    #   opts = [except: [species_id: id_of(species: Second)]]
    #   actual = run.(:example, SomeModule, opts)

    #   assert Pnode.EENable.eens(actual) == [een(example: SomeModule),
    #                                        een(species: Second)]
    #   assert actual.with_ensured_eens == %{reference_een: een(example: SomeModule),
    #                                        opts: opts}
    # end
  end

  test "export" do
    # input = %Pnode.FieldsLike{with_ensured_eens: %{reference_een: "...some een...",
    #                                               opts: "...some opts..."}}

    # expected = %Rnode.FieldsLike{een: "...some een...", opts: "...some opts..."}

    # assert Pnode.Exportable.export(input) == expected
  end
end  
