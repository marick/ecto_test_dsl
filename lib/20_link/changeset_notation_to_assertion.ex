defmodule TransformerTestSupport.Link.ChangesetNotationToAssertion do
  use TransformerTestSupport.Drink.Me
  alias Ecto.Changeset
  alias FlowAssertions.Ecto.ChangesetA
  import FlowAssertions.Define.BodyParts, only: [adjust_assertion_error: 2]

  @moduledoc """
  A function that might throw an AssertionError about a given changeset.
  Plus, for debugging, where that assertion came from.

  Note that this is created at Link time because a changeset assertion
  might depend on, say, the ID of another assertion.
  """

  defstruct [:runner, :from]

  def from(list) when is_list(list) do
    for one <- list, do: from(one)
  end

  def from(check_name) when is_atom(check_name) do 
    f = fn changeset ->
      apply ChangesetA, assert_name(check_name), [changeset]
    end
    new(f, check_name)
  end

  def from({check_name, arg} = item) do 
    f = fn changeset ->
      apply ChangesetA, assert_name(check_name), [changeset, arg]
    end
    new(f, item)
  end

  def new(f, from), do: %__MODULE__{runner: f, from: from}
  
  def check(assertion, %Changeset{} = changeset) do
    adjust_assertion_error(fn -> 
      assertion.runner.(changeset)
      :ok
    end,
      expr: [changeset: [assertion.from, "..."]])
  end

  defp assert_name(changeset_check),
    do: "assert_#{to_string changeset_check}" |> String.to_atom
end
