defmodule Integration.GranularInsertion.Workflow.Test do
  use EctoTestDSL.Case
  alias Integration.GranularInsertion.Workflow.Examples
  use Integration.Support

  @tag :skip
  test "Have params_like accept a `deleting` option so that `only_required` can be derived from `complete`."

  test "params step" do
    Examples.Tester.params(:complete)
    |> assert_same_map(%{
          "age" => "55",
          "date_string" => "2000-01-02",
          "species_id" => "1",
          "defaulted_comment" => "defaulted comment override",
          "optional_comment" => "optional comment"})

    Examples.Tester.params(:only_required)
    |> assert_same_map(%{
          "age" => "55",
          "date_string" => "2000-01-02",
          "species_id" => "1"})
  end

  describe "validation step" do
    test "fetching changeset" do
      only_required_changeset = Examples.Tester.validation_changeset(:only_required)

      only_required_changes = %{
        age: 55,
        date_string: "2000-01-02",
        date: ~D[2000-01-02],
        days_since_2000: 1,
        species_id: 1
      }
      
      only_required_changeset
      |> assert_valid
      |> assert_changes(only_required_changes)

      complete_changeset = Examples.Tester.validation_changeset(:complete)

      complete_changes =
        Map.merge(only_required_changes, %{
              optional_comment: "optional comment",
              defaulted_comment: "defaulted comment override"})
      
      complete_changeset
      |> assert_valid
      |> assert_changes(complete_changes)
    end

    test "an error in an `on_success` short-circuits later checks" do
      Examples.Tester.validation_changeset(:unexpected_syntax_errors)
      |> assert_invalid
      |> assert_no_changes([:age, :date, :days_since_2000])
         # Note that there is no attempt to calculate :days_since_2000
      |> assert_errors(age: "is invalid",
                       date_string: "has an invalid format")
    end
      
    test "mistakes in test data" do
      assertion_fails(~r/workflow `:success` expects a valid changeset/,
        fn -> 
          Examples.Tester.check_workflow(:unexpected_syntax_errors)
        end)

      assertion_fails(~r/Field `:days_since_2000` has the wrong value/,
        [left: 1, right: 5],
        fn -> 
          Examples.Tester.check_workflow(:override_incorrectly)
        end)
    end
  end

  describe "insertions" do
    test "retrieving inserted value" do
      insert_returns {:ok, "some schema structure"}
      assert "some schema structure" = Examples.Tester.inserted(:complete)
    end

    test "unexpected failure" do
      insert_returns {:error, "some changeset"}
      
      assertion_fails(~r/Example `:insertion_will_unexpectedly_fail`/,
        [message: ~r/Value is not an `:ok` tuple/, 
        left: {:error, "some changeset"}],
        fn -> 
          Examples.Tester.check_workflow(:insertion_will_unexpectedly_fail)
        end)
    end
  end

  test "end-to-end success" do
    insert_returns {:ok, "irrelevant"}

    Examples.Tester.check_workflow(:complete)
    Examples.Tester.check_workflow(:only_required)
  end
end
