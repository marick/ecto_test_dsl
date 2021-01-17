defmodule ModuleXTest do

  defmodule Struct do
    defstruct [:top, :t1, :t2]
  end

  defmodule GetterTest do
    use ExUnit.Case
    import TransformerTestSupport.ModuleX

    getters [:t1, :t2]
    
    test "getters" do
      assert t1(%Struct{t1: 5}) == 5
      assert t2(%Struct{t2: 50}) == 50
      assert_raise(KeyError, fn -> t1(%{}) end)
    end
    
    getters :top, [:lower]

    test "two-level getters" do
      assert lower(%Struct{top: %{lower: 5}}) == 5
    end

    getters :top, :middle, [:bottom]

    test "three-level getters" do
      assert bottom(%Struct{top: %{middle: %{bottom: 5}}}) == 5
    end
  end


  defmodule DefaultingTest do
    use ExUnit.Case
    import TransformerTestSupport.ModuleX

    getters([:t1, t2: :default])
    
    test "getters" do
      assert t1(%{t1: 383}) == 383
      assert_raise(KeyError, fn -> t1(%{}) end)

      assert t2(%{t2: 383}) == 383
      assert t2(%{}) == :default
    end
    
    getters :top, [lower: :default]

    test "two-level getters" do
      assert lower(%Struct{top: %{lowerx: 5}}) == :default
    end

    getters :top, :middle, [:m, bottom: :default]

    test "three-level getters" do
      assert bottom(%Struct{top: %{middle: %{m: 5}}}) == :default
    end
  end

  defmodule PrivateGetterTest do
    use ExUnit.Case
    import TransformerTestSupport.ModuleX

    private_getters [:t1, t2: 33]
    
    test "created" do
      assert t1(%{t1: 5}) == 5
      assert t2(%{t1: 5}) == 33
      assert_raise(KeyError, fn -> t1(%{}) end)
    end

    test "private" do
      refute Kernel.function_exported?(__MODULE__, :t1, 1)
    end

    publicize(:that_t, renames: :t1)

    test "publicize" do
      assert that_t(%{t1: 5}) == 5
      assert Kernel.function_exported?(__MODULE__, :that_t, 1)
    end
  end

  defmodule MixerTest do
    use ExUnit.Case
    import TransformerTestSupport.ModuleX

    getters :example, :history, [:params, changeset: %{}]

    test "mixtures of keyword lists and maps" do
      assert params(%{example:  [m: 3, history: [params: 5]]}) == 5
      assert changeset(%{example:  [m: 3, history: [params: 5]]}) == %{}
      assert changeset(%{example: %{m: 3, history: [changeset: "..."]}}) == "..."
    end
  end
    
end
