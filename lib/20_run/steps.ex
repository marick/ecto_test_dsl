defmodule EctoTestDSL.Run.Steps do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AssertionJuice
  use EctoTestDSL.Drink.AndRun
  import T.Run.Steps.Util

  # ----------------------------------------------------------------------------

  # I can't offhand think of any case where one `repo_setup` might need to
  # use the results of another that isn't part of the same dependency tree.
  # That might change if I add a workflowy-wide or test-data-wide setup.

  # If that is done, the history must be passed in by `Run.example`

  def start_sandbox(example) do
    alias Ecto.Adapters.SQL.Sandbox

    repo = Example.repo(example)
    if repo do  # Convenient for testing, where we might be faking the repo functions.
      Sandbox.checkout(repo) # it's OK if it's already checked out.
    end
  end

  def repo_setup(running) do
    from(running, use: [:neighborhood, :eens])
    Enum.reduce(eens, neighborhood, &Neighborhood.Create.from_an_een/2)
  end

  # ----------------------------------------------------------------------------
  def params(running) do
    from(running, use: [:neighborhood, :original_params])

    params = 
      RunningExample.formatted_params_for_history(running,
        Neighborhood.Expand.keyword_values(original_params, with: neighborhood))

    Trace.say(params, :params)
    params
  end

end
