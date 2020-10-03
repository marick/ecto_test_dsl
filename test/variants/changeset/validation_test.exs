defmodule Variants.Changeset.ValidationTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Variants.Changeset
#  import FlowAssertions.AssertionA
  import FlowAssertions.Define.Tabular

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

  defmodule Params do
    use TransformerTestSupport.Impl.Predefines
    alias TransformerTestSupport.Variants.Changeset
    
    def create_test_data do 
      start(
        module_under_test: Schema,
        format: :phoenix,
        variant: Changeset
      )
    end
  end

  def make_changeset(params) do
    Changeset.validate_params(%{module_under_test: Schema}, params)
  end

  describe " validating params produces a changeset" do
    test "valid" do
      make_changeset(%{"date" => "2001-02-02"})
      |> assert_valid
      |> assert_changes(date: ~D/2001-02-02/)
    end

    test "invalid" do
      make_changeset(%{"date" => "2001-02-"})  
      |> assert_invalid
      |> assert_no_changes(:date)
      |> assert_error(date: ~r/is invalid/)
    end
  end

  describe "validating assertions" do
    setup do
      asserter = fn changeset, checks -> 
        example = %{changeset: checks}
        Changeset.validation_assertions(changeset, :example_name, example)
      end
      [a: assertion_runners_for(asserter)]
    end

    test "a valid changeset", %{a: a} do
      changeset = make_changeset(%{"date" => "2001-02-02"})
      
      [changeset, [:valid]]   |> a.pass.()
      [changeset, [:invalid]] |> a.fail.(
        ~R/changeset is supposed to be invalid/)

      [changeset, [change: [date: ~D/2001-02-02/]]]  |> a.pass.()
      [changeset, [change: [date: ~D/2111-11-11/]]]  |> a.fail.(
        ~r/Field `:date` has the wrong value/)
      
    end

    test "an invalid changeset", %{a: a} do
      changeset = make_changeset(%{"date" => "2001-02-2"})
                                                    #^^   improper date field
      [changeset, [:invalid]] |> a.pass.()
      [changeset, [:valid]]   |> a.fail.(
        ~R/changeset is invalid/)

      [changeset, [:no_changes]]                     |> a.pass.()
      [changeset, [no_changes: [:date]]]             |> a.pass.()

      [changeset, [change: [date: ~D/2111-11-11/]]]  |> a.fail.(
        ~R/Field `:date` is missing/)
    end

    test "it's OK for there to be no assertions" do
      changeset = make_changeset(%{"date" => "2001-02-2"})

      Changeset.validation_assertions(changeset, :example_name, %{})      
      |> assert_equal(changeset)
      
      Changeset.validation_assertions(changeset, :example_name, %{changeset: []})
      |> assert_equal(changeset)
    end
  end
end
