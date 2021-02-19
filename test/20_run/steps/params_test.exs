defmodule Run.Steps.ParamsTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  import T.RunningStubs
  alias Run.Steps
  alias Run.Rnode
  import T.Parse.InternalFunctions

  describe "ordinary params" do
    test "substitutions" do
      input =    Rnode.Params.new(%{ a:     1,   b_id: id_of(b: Module)})
      expected =                  %{"a" => "1", "b_id" => "383"}

      stub(original_params: input, format: :phoenix)
      stub(neighborhood: %{een(b: Module) => %{id: 383}})

      assert Steps.params(:running) == expected
    end
  end

  defmodule Schema do
    defstruct [:a, :b_id, :extra]
  end


  describe "params from repo" do
    test "substitutions without exceptions" do
      stub(neighborhood: %{
            een(existing: Schema) => %Schema{a: "a", b_id: 383, extra: 5}})

      input = Rnode.ParamsFromRepo.new(een(existing: Schema), %{})
      expected = %{"a" => "a", "b_id" => "383", "extra" => "5"}

      stub(original_params: input, format: :phoenix)

      assert Steps.params(:running) == expected
    end

    test "substitutions with exceptions" do 
      stub(neighborhood: %{
            een(existing: Schema) => %Schema{a: "replaced", b_id: "replaced", extra: 5},
            een(b: Module) => %{id: 383}})

      input = Rnode.ParamsFromRepo.new(een(existing: Schema),
        %{a: "new", b_id: id_of(b: Module)})
      expected = %{"a" => "new", "b_id" => "383", "extra" => "5"}

      stub(original_params: input, format: :phoenix)

      assert Steps.params(:running) == expected
    end
  end
end
