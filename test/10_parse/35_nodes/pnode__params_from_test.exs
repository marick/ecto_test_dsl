defmodule EctoTestDSL.Parse.Pnode.ParamsFromTest do
  use EctoTestDSL.Case
  alias T.Parse.Pnode
  alias T.Run.Rnode
  import T.Parse.InternalFunctions

  describe "creation" do
    test "normal" do
      Pnode.ParamsFrom.parse(een(:name), except: [a: 1])
      |> assert_fields(reference_een: een(:name),
                       opts: [except: [a: 1]],
                       eens: [een(:name)])
    end
    
    test "an een is required" do
      assertion_fails(~r/Perhaps you meant `een\(name: SomeExamples\)`/,
        [left: :name], fn -> 
          Pnode.ParamsFrom.parse(:name, [except: [a: 1]])
        end)
    end

    test "een is *really* wrong" do
      assertion_fails(~r/Perhaps you meant `een\(some_name: SomeExamples\)`/,
        [left: "name"], fn -> 
          Pnode.ParamsFrom.parse("name", [except: [a: 1]])
        end)
    end

    test "bad options" do
      assertion_fails(~r/`params_from`'s second argument must be `except: <keyword_list>`/,
        [left: [excep: [a: 1]]], fn -> 
          Pnode.ParamsFrom.parse(een(:name), [excep: [a: 1]])
        end)
    end

    test "no option works too" do
      {:params, actual} = Parse.ExampleFunctions.params_from(een(:name))
      expected = Pnode.ParamsFrom.parse(een(:name), except: [])
      assert actual == expected
    end
  end

  describe "eens" do
    test "een and id_of" do
      actual =
        Pnode.ParamsFrom.parse(een(:name), [except: [a: id_of(:other)]])

      assert Pnode.EENable.eens(actual) == [een(:name), een(other: __MODULE__)]
    end
  end

  test "export" do
    input =
      Pnode.ParamsFrom.parse(een("...some een..."), except: [x_id: id_of(:x)])

    expected = %Rnode.ParamsFrom{
      een: een("...some een..."),
      except: %{x_id: id_of(:x)}}

    assert Pnode.Exportable.export(input) == expected
  end
end  
