defmodule BuildTest do
  use TransformerTestSupport.Drink.Me
  use T.Case
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
      assert id_of(animal: Examples) ==
         {:__previously_reference, een_t(animal: Examples), :primary_key}
      assert id_of(:animal) == 
         {:__previously_reference, een_t(animal: __MODULE__), :primary_key}
    end
    
    test "id_of works within params_like as well" do
      previous = [
        template:   %{params: %{a: 1, b: 2 }},
        previously: %{}
      ]
      f = Build.make__params_like(:template,
        except: [b: id_of(:previously), c: 3])

      %{params: %{b: b}} = Build.ParamShorthand.expand(%{params: f}, :example, previous)
      assert b == {:__previously_reference, een_t(previously: __MODULE__),
                   :primary_key}
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

  test "field transformations" do
    args = [
      as_cast: [:date_string, :id],
      date: on_success(Date.from_iso8601!(:date_string))
    ]
    
    %{field_transformations: %{}}
    |> Build.field_transformations(args)
    |> assert_field(field_transformations: args)
    # Note that field transformations are run in order.
  end

  def function_in_module(x), do: x - 3
  
  test "on_success, specifically" do
    assert {:__on_success, &Date.diff/2, [:date, ~D[2000-01-01]]} ==
      on_success(Date.diff(:date, ~D[2000-01-01]))

    assert {:__on_success, &List.Chars.to_charlist/1, [:date]} ==
      on_success(List.Chars.to_charlist(:date))

    assert {:__on_success, function, [:date]} =
      on_success(function_in_module(:date))
    assert function.(3) == 0


    # The variant that accepts functions
    f = &(&1 + 1)
    assert {:__on_success, f, [:date]} ==
      on_success(f, applied_to: :date)
  end
    
  test "metadata propagation" do
    Examples.start(@minimal_start)
    |> Build.workflow(:valid, ok: [params(age: 1)])
    |> Build.propagate_metadata
    |> SmartGet.Example.get(:ok)
    |> Map.get(:metadata)
    |> assert_fields(workflow_name: :valid,
                     name: :ok,
                     module_under_test: SomeSchema,
                     variant: T.Variants.Trivial)
    |> refute_field(:examples)
  end
end