defmodule Variants.EctoClassic.SingleExampleValidationTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Variants.EctoClassic
  import FlowAssertions.Define.Tabular
  alias TransformerTestSupport.Build

  defmodule Schema do 
    use Ecto.Schema
    import Ecto.Changeset

    embedded_schema do
      field :date, :date
    end

    def changeset(struct, params) do
      struct
      |> cast(params, [:date])
      |> validate_required([:date])
    end
  end


  @base_test_data %{module_under_test: Schema, format: :phoenix}

  defp test_data(opts \\ []) do
    example = Enum.into(opts, %{})
    Map.put(@base_test_data, :examples,  [example: example])
    |> Build.propagate_metadata
  end

  defp validate_params(params), 
    do: EctoClassic.validate_params(test_data(params: params), :example)

  describe " validating params produces a changeset" do
    test "valid" do
      validate_params(%{date: "2001-02-02"})
      |> assert_valid
      |> assert_changes(date: ~D/2001-02-02/)
    end

    test "invalid" do
      validate_params(%{date: "2001-02-"})
      |> assert_invalid
      |> assert_no_changes(:date)
      |> assert_error(date: ~r/is invalid/)
    end
  end

  describe "validating assertions" do
    setup do
      asserter = fn changeset, checks ->
        test_data = test_data(changeset: checks)
        EctoClassic.validation_assertions(changeset, test_data, :example)
      end
      [a: assertion_runners_for(asserter)]
    end

    test "a valid changeset", %{a: a} do
      changeset = validate_params(%{date: "2001-02-02"})
      
      [changeset, [:valid]]   |> a.pass.()
      [changeset, [:invalid]] |> a.fail.(
        ~R/changeset is supposed to be invalid/)

      [changeset, [change: [date: ~D/2001-02-02/]]]  |> a.pass.()
      [changeset, [change: [date: ~D/2111-11-11/]]]  |> a.fail.(
        ~r/Field `:date` has the wrong value/)
    end

    test "an invalid changeset", %{a: a} do
      changeset = validate_params(date: "2001-02-2")
                                                #^^   improper date field
      [changeset, [:invalid]] |> a.pass.()
      [changeset, [:valid]]   |> a.fail.(
        ~R/changeset is invalid/)

      [changeset, [:no_changes]]                     |> a.pass.()
      [changeset, [no_changes: [:date]]]             |> a.pass.()

      [changeset, [change: [date: ~D/2111-11-11/]]]  |> a.fail.(
        ~R/Field `:date` is missing/)
    end

    test "it's OK for there to be no assertions", %{a: a} do
      changeset = validate_params(%{date: "2001-02-2"})

      [changeset, []] |> a.pass.()

      EctoClassic.validation_assertions(changeset, test_data(), :example)
      |> assert_equal(changeset)
    end
  end
end
