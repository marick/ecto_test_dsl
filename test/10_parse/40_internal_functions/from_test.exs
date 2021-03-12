defmodule Parse.InternalFunctions.FromTest do
  use EctoTestDSL.Case
  use T.Predefines
  alias T.Parse.BuildState

  @een een(animal: Examples)

  setup do
    BuildState.put(%{examples_module: Examples})
    :ok
  end

  test "parsing without options" do
    check = fn arg ->
      assert from(arg) == StructRef.new(@een, [])
    end

    check.(@een)
    check.(animal: Examples)
    check.(:animal)
  end
    

  test "parsing with options" do
    expected = StructRef.new(@een, [except: [a: 1]])

    assert from(@een, except: [a: 1]) == expected
    assert from(animal: Examples, except: [a: 1]) == expected
    assert from(:animal, except: [a: 1]) == expected
    
  end
    
  

    
      
    # @plain_expected StructRef.new(@een, [])
    # @expected_with_opts StructRef.new(@een, [except: [a: 1]])
    
    # test "an een" do
    #   assert from(@een, except: [a: 1]) == 
    # end

    # test "a starting description" do
      
    #   assert from(animal: Examples, except: [a: 1]) == StructRef.new(@een, [except: [a: 1]])
    # end
    
    # # test "just a name" do
    # #   

    # #   een = een(animal: Examples)
    
    # #   assert from(animal: Examples) == StructRef.new(een, [])
    # #   assert from(animal: Examples, except: [a: 1]) == StructRef.new(een, [except: [a: 1]])
    # # end
    
  # end
end

