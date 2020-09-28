defmodule Impl.GetTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl.Get
  import FlowAssertions.AssertionA


  describe "categories" do
    @category_test_data %{
      examples: %{
        in_none: %{},
        just_valid: %{categories: [:valid]},
        just_invalid: %{categories: [:invalid]},

        in_two: %{categories: [:valid, :blank]},
        just_blank: %{categories: [:blank]},

        extra: %{categories: [:extra]}
      }
    }


    test "in_all_categories" do
      in_all? = fn [name, categories], expected ->
        assert expected ==
          Get.in_all_categories?(@category_test_data, name, categories)
      end
      
      [:in_none,      [:valid] ] |> in_all?.(false)
      [:just_valid,   [:valid] ] |> in_all?.(true)
      [:just_invalid, [:valid] ] |> in_all?.(false)
      
      [:in_two,       [:valid, :blank]]         |> in_all?.(true)
      [:in_two,       [:valid, :blank, :extra]] |> in_all?.(false)
      [:just_valid,   [:valid, :blank]]         |> in_all?.(false)
    end

    test "names_in_categories" do
      run = fn categories ->
        Get.names_in_categories(@category_test_data, categories)
      end

      pass = fn categories, expected ->
        assert_good_enough(run.(categories), in_any_order(expected))
      end
      
      [:valid]         |> pass.([:just_valid, :in_two])
      [:blank]         |> pass.([:just_blank, :in_two])
      [:blank, :valid] |> pass.([:in_two])
      
      [:valid, :invalid] |> pass.([])
    end

    test "check_valid_categories" do
      Get.ensure_valid_categories(@category_test_data, [:extra])

      assertion_fails(
        "Categories you asked for don't exist",
        [left: [:ok]],
        fn ->
          Get.ensure_valid_categories(@category_test_data, [:ok])          
        end)
    end
  end
end 
