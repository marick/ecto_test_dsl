defmodule Impl.BuildTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl
  alias TransformerTestSupport.Impl.Build
  use TransformerTestSupport.Impl.Predefines
  alias TransformerTestSupport.Impl.SmartGet

  defmodule Variant do
    def run_start_hook(test_data),
      do: Map.put(test_data, :adjusted, true)
  end

  @minimal_start [module_under_test: Anything, variant: Variant]

  test "minimal start" do
    expected = 
      %{format: :raw,
        module_under_test: Anything,
        variant: Variant,
        examples: [],
        adjusted: true,
        field_transformations: [],
        workflow: :insert
       }
    
    assert Build.start(@minimal_start) == expected
  end

  test "params_like" do
    previous = [ok: %{params:                   %{a: 1, b: 2 }}]
    f = Build.make__params_like(:ok, except:           [b: 22, c: 3])
    expected =      %{params:                   %{a: 1, b: 22, c: 3}}

    assert Impl.Build.Like.expand(%{params: f}, :example, previous) == expected
  end


  test "category" do
    %{examples: [new: new, ok: ok]} =
      Build.start(@minimal_start)
      |> Build.category(:valid,
           ok: [params(age: 1)],
           new: [params_like(:ok, except: [age: 2])])

      assert ok.params == %{age: 1}
      assert new.params == %{age: 2}

      assert ok.metadata.category_name == :valid
      assert ok.metadata.name == :ok
      assert new.metadata.category_name == :valid
      assert new.metadata.name == :new
  end

  test "field_transformations" do
    %{field_transformations: %{}}
    |> Build.field_transformations(age: :as_cast)
    |> assert_field(field_transformations: [age: :as_cast])
    # Note that field transformations are run in order.
  end

  test "metadata propagation" do
    Build.start(@minimal_start)
    |> Build.category(:valid, ok: [params(age: 1)])
    |> Build.propagate_metadata
    |> SmartGet.example(:ok)
    |> Map.get(:metadata)
    |> assert_fields(category_name: :valid,
                     name: :ok,
                     module_under_test: Anything,
                     variant: Variant)
    |> refute_field(:examples)
  end
end
