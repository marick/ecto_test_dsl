defmodule Build.StepTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport, as: T
  alias T.Build
  alias T.Variants.EctoClassic

  

  defmodule Examples do
    use EctoClassic
    
    def create_without_step_change do 
      start_with_variant(EctoClassic, module_under_test: Anything)
    end

    def create_test_data() do
      create_without_step_change()
      |> replace_steps(check_validation_changeset: &(&1 + 1)) # bogus value
    end
  end

  @tag :skip
  test "Describe the behavior without replacement" do
    # steps = Examples.create_without_step_change.workflow_steps
    # assert steps == EctoClassic.steps
    # assert Keyword.get(steps, :check_validation_changeset)
  end

  @tag :skip
  test "steps can be overridden" do
    # steps = Examples.create_test_data.workflow_steps
    # assert Keyword.get(steps, :check_validation_changeset).(1) == 2
  end    

end
