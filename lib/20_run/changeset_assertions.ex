defmodule TransformerTestSupport.Run.ChangesetAssertions do
  use TransformerTestSupport.Drink.Me
  use TransformerTestSupport.Drink.AssertionJuice

  @moduledoc """
  A function that might throw an AssertionError about a given changeset.
  Plus, for debugging, where that assertion came from.

  Note that this is created at Neighborhood time because a changeset assertion
  might depend on, say, the ID of another assertion.
  """

  defstruct [:runner, :from]

  def from(list) when is_list(list) do
    for one <- list, do: from(one)
  end

  def from(check_name) when is_atom(check_name) do 
    f = fn changeset ->
      apply ChangesetA, assert_name(check_name), [changeset]
      :ok
    end
    friendlier_location(f, check_name)
  end

  def from({check_name, arg} = item) do 
    f = fn changeset ->
      apply ChangesetA, assert_name(check_name), [changeset, arg]
      :ok
    end
    friendlier_location(f, item)
  end

  def new(f, from), do: %__MODULE__{runner: f, from: from}
  
  defp friendlier_location(f, from) do 
    fn changeset ->
      adjust_assertion_error(fn -> 
        f.(changeset)
      end,
        expr: [changeset: [from, "..."]])
    end
  end


  defp assert_name(changeset_check),
    do: "assert_#{to_string changeset_check}" |> String.to_atom
end
