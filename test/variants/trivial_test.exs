defmodule Variants.TrivialTest do
  use EctoTestDSL.Case
  use T.Predefines
  alias T.Nouns.AsCast

  defmodule Examples do
    use Template.Trivial
  end

  describe "start" do 
    @minimal_start [
      module_under_test: SomeSchema,
    ]
    
    test "adds steps, workflows, etc." do
      expected = 
        %{format: :raw,
          module_under_test: SomeSchema,
          variant: T.Variants.Trivial,
          examples: [],
          as_cast: AsCast.nothing,
          field_calculators: [],
          steps: %{},
          workflows: %{}
         }
      
      assert Examples.start(@minimal_start) == expected
    end
  end
        
end
