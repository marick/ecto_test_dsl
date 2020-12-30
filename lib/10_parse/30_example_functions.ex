defmodule TransformerTestSupport.Parse.ExampleFunctions do
  use TransformerTestSupport.Drink.Me
  import FlowAssertions.Define.BodyParts

  # ----------------------------------------------------------------------------
  def params(opts \\ []),
    do: {:params, Enum.into(opts, %{})}
  
  def params_like(example_name, opts),
    do: {:params, make__params_like(example_name, opts)}
  def params_like(example_name), 
    do: params_like(example_name, except: [])

  @doc false
  # Exposed for testing.
  def make__params_like(previous_name, except: override_kws) do 
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

  # ----------------------------------------------------------------------------
  # Nothing is 
  
  def previously(opts) do
    {:setup_instructions, opts}
  end

  def changeset(opts), do: {:changeset_for_validation_step, opts}
  def constraint_changeset(opts), do: {:changeset_for_constraint_step, opts}

  # ----------------------------------------------------------------------------

  # This is expanded during normalization.
  def insert_twice(example_name),
    do: {:__flatten, [previously(insert: example_name), params_like(example_name)]}

end
