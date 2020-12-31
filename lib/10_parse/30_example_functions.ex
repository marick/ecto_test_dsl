defmodule TransformerTestSupport.Parse.ExampleFunctions do
  use TransformerTestSupport.Drink.Me
  import FlowAssertions.Define.BodyParts
  alias Parse.Nouns.DeferredParams

  # ----------------------------------------------------------------------------
  def params(opts \\ []),
    do: {:params, Enum.into(opts, %{})}
  
  def params_like(example_name, opts),
    do: {:params, DeferredParams.like(example_name, opts)}
  def params_like(example_name), 
    do: params_like(example_name, except: [])


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
