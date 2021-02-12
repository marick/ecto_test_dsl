defmodule Run.Steps.FieldsLikeTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias Run.Steps.Ecto, as: Steps
  use Mockery
  import T.RunningStubs
  import T.Parse.InternalFunctions

  setup do
    stub(name: :example, neighborhood: %{})
    stub(field_checks: %{})
    :ok
  end

  @reference_een een(:other)

  defp run(~M{under_test, reference_value, opts}) do 
    stub_history(inserted_value: under_test)
    stub(neighborhood: %{@reference_een => reference_value})
    stub(fields_like: Run.Node.FieldsLike.new(@reference_een, opts))
    Steps.field_checks(:running, :inserted_value)
  end

  defp pass(setup), do: assert run(setup) == :uninteresting_result

  describe "various ways of passing" do
    test "just an een: pass" do
      %{under_test: %{a: 5},
        reference_value: %{a: 5},
        opts: []}
      |> pass()
    end

    test "just an een: fail" do
      %{under_test: %{a: 5},
        reference_value: %{a: 4},
        opts: []}
      |> run()
    end
    
  end
    
  # test "expected change has wrong value" do
  #   input = [ %{name: "Bossie"}, %{name: ""}]
    
  #   assertion_fails(~r/Example `:example`/,
  #     [message: ~r/Field `:name` has the wrong value/,
  #      left: "",
  #      right: "Bossie"],
  #     fn ->
  #       run(input)
  #     end)
  # end

  # test "extra values are OK" do
  #   [ %{name: "Bossie"}, %{name: "Bossie", age: 5}] |> pass
  # end

  # test "references to neighbors are supported" do
  #   other_een = een(:other_example)
  #   stub(neighborhood: %{other_een => %{id: 333}})

  #   passes = [ %{other_id: id_of(:other_example)}, %{other_id: 333}]
  #   fails =  [ %{other_id: id_of(:other_example)}, %{other_id: "NOT"}]

  #   passes |> pass()

  #   assertion_fails(~r/Example `:example`/,
  #     [message: ~r/Field `:other_id` has the wrong value/,
  #      left: "NOT",
  #      right: 333],
  #     fn ->
  #       run(fails)
  #     end)
  # end
end
