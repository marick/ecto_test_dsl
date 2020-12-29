defmodule BuildTest do
  use TransformerTestSupport.Case
  use T.Predefines

  defmodule Examples do
    use Template.Trivial
  end

  @minimal_start [
    module_under_test: SomeSchema,
  ]

  describe "start" do
    # Start is described in variant-specific tests
  end
        
        
  describe "params" do 
    test "params_like" do
      previous = [ok: %{params:                   %{a: 1, b: 2 }}]
      f = Build.make__params_like(:ok, except:           [b: 22, c: 3])
      expected =      %{params:                   %{a: 1, b: 22, c: 3}}
      
      assert Build.ParamShorthand.expand(%{params: f}, :example, previous) == expected
    end

    test "id_of" do
      assert id_of(animal: Examples) == FieldRef.new(id: een(animal: Examples))
      assert id_of(:animal) == FieldRef.new(id: een(animal: __MODULE__))
    end
    
    test "id_of works within params_like as well" do
      previous = [
        template:   %{params: %{a: 1, b: 2 }},
        previously: %{}
      ]
      f = Build.make__params_like(:template,
        except: [b: id_of(:previously), c: 3])

      %{params: %{b: b}} = Build.ParamShorthand.expand(%{params: f}, :example, previous)
      assert b == FieldRef.new(id: een(previously: __MODULE__))
    end
  end

  test "workflow" do
    %{examples: [new: new, ok: ok]} =
      Examples.start(@minimal_start)
      |> Build.workflow(:valid,
           ok: [params(age: 1)],
           new: [params_like(:ok, except: [age: 2])])

      assert ok.params == %{age: 1}
      assert new.params == %{age: 2}

      assert ok.metadata.workflow_name == :valid
      assert ok.metadata.name == :ok
      assert new.metadata.workflow_name == :valid
      assert new.metadata.name == :new
  end

  def function_in_module(x), do: x - 3

  test "on_success, specifically" do
    
    on_success(Date.diff(:date, ~D[2000-01-01]))
    |> assert_fields(calculation: &Date.diff/2,
                     args: [:date, ~D[2000-01-01]],
                     from: "on_success(Date.diff(:date, ~D[2000-01-01]))")
                          
    on_success(List.Chars.to_charlist(:date))
    |> assert_fields(calculation: &List.Chars.to_charlist/1,
                     args: [:date],
                     from: "on_success(List.Chars.to_charlist(:date))")
                          

    on_success(function_in_module(:date))
    |> assert_fields(calculation: &BuildTest.function_in_module/1,
                     args: [:date],
                     from: "on_success(function_in_module(:date))")
    
    # The variant that accepts functions
    f = &(&1 + 1)
    on_success(f, applied_to: :date)
    |> assert_fields(calculation: f,
                     args: [:date],
                     from: "on_success(<fn>, applied_to: [:date])")
  end
    
end
