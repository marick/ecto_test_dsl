defmodule BuildTest do
  use TransformerTestSupport.Case
  use T.Predefines

  defmodule Examples do
    use Template.Trivial
  end

  describe "start" do
    # Start is described in variant-specific tests
  end
        
        
  describe "params" do 
    
    # test "id_of works within params_like as well" do
    #   previous = [
    #     template:   %{params: %{a: 1, b: 2 }},
    #     previously: %{}
    #   ]
    #   f = Build.make__params_like(:template,
    #     except: [b: id_of(:previously), c: 3])

    #   %{params: %{b: b}} = Build.ParamShorthand.expand(%{params: f}, :example, previous)
    #   assert b == FieldRef.new(id: een(previously: __MODULE__))
    # end
  end


    
end
