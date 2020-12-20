defmodule TransformerTestSupport.Link.ChangesetNotationToAssertion do
  use TransformerTestSupport.Drink.Me
  alias Ecto.Changeset
  alias FlowAssertions.Ecto.ChangesetA

  @moduledoc """
  A function that might throw an AssertionError about a given changeset.
  Plus, for debugging, where that assertion came from.

  Note that this is created at Link time because a changeset assertion
  might depend on, say, the ID of another assertion.
  """

  defstruct [:runner, :from]

  def from(check_name) when is_atom(check_name) do 
    f = fn changeset ->
      apply ChangesetA, assert_name(check_name), [changeset]
    end
    from(f, check_name)
  end

  def from({check_name, arg} = item) do 
    f = fn changeset ->
      apply ChangesetA, assert_name(check_name), [changeset, arg]
    end
    from(f, item)
  end

  def from(f, from), do: %__MODULE__{runner: f, from: from}
  
  def check(assertion, %Changeset{} = changeset) do
    assertion.runner.(changeset)
    :ok
  end

  defp assert_name(changeset_check),
    do: "assert_#{to_string changeset_check}" |> String.to_atom
end
