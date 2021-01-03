defmodule TransformerTestSupport.Parse.Nouns.ParamsLike do
  use TransformerTestSupport.Drink.Me
  use TransformerTestSupport.Drink.AssertionJuice

  # This doesn't really need to be a struct, but having a named
  # thing is simpler than having an anonymous function floating around.

  defstruct [:resolver]

  def new(previous_name, except: override_kws) do
    overrides = Enum.into(override_kws, %{})
    resolver = fn named_examples ->
      case Keyword.get(named_examples, previous_name) do
        nil ->
          ex = inspect previous_name
          elaborate_flunk("There is no previous example `#{ex}`",
            right: Keyword.keys(override_kws))
        previous -> 
          Map.merge(previous.params, overrides)
      end
    end

    %__MODULE__{resolver: resolver}
  end

  def resolve(%__MODULE__{resolver: resolver}, existing_named_examples),
    do: resolver.(existing_named_examples)

  def resolve(already_resolved, _) when is_map(already_resolved),
    do: already_resolved
end  
