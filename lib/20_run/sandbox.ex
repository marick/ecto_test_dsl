defmodule EctoTestDSL.Run.Sandbox do
  use EctoTestDSL.Drink.Me
  alias Ecto.Adapters.SQL.Sandbox

  # Note: this won't try to check the repo out unless it exists
  # and is a symbol (which should always be a Repo module). This
  # is just for testing this library.
  #
  # Kludgily, that means that fake repo values should be a string rather
  # than something like `:no_repo_is_used`. And that's because the
  # variants check for the user error of forgetting to name the repo.
  def start(example) do
    repo = Example.repo(example)
    if repo && is_atom(repo) do  
      Sandbox.checkout(repo) # it's OK if it's already checked out.
    end
  end
end
