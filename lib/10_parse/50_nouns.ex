defmodule TransformerTestSupport.Parse.Nouns do
  use TransformerTestSupport.Drink.Me
  alias T.Nouns.AsCast
  alias T.Parse.Hooks
  import FlowAssertions.Define.BodyParts

  defmodule DeferredParams do
    def like(previous_name, except: override_kws) do
      overrides = Enum.into(override_kws, %{})
      fn named_examples ->
        case Keyword.get(named_examples, previous_name) do
          nil ->
            ex = inspect previous_name
            elaborate_flunk("There is no previous example `#{ex}`",
              right: Keyword.keys(override_kws))
          previous -> 
            Map.merge(previous.params, overrides)
        end
      end
    end


    def resolve(already_resolved, _) when is_map(already_resolved),
      do: already_resolved

    def resolve(f, existing_named_examples),
      do: f.(existing_named_examples)
  end
end  
