defmodule EctoTestDSL.Parse.ExampleFunctions do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AssertionJuice
  alias T.Parse.Node

  # ----------------------------------------------------------------------------
  def params(opts \\ []),
    do: {:params, Node.Params.parse(opts)}
  
  def params_like(example_name, opts),
    do: {:params, Node.ParamsLike.parse(example_name, opts)}
  def params_like(example_name), 
    do: params_like(example_name, except: [])


  # ----------------------------------------------------------------------------
  
  def previously(opts), 
    do: {:previously, Node.Previously.parse(opts)}

  def changeset(opts),
    do: {:validation_changeset_checks, Node.ChangesetChecks.parse(opts)}
  def constraint_changeset(opts),
    do: {:constraint_changeset_checks, Node.ChangesetChecks.parse(opts)}

  def fields(opts), do: {:field_checks, opts}

  def params_from_selecting(een, _opts \\ [except: []]) do
    {:params_from_selecting, een}
  end
  

  # ----------------------------------------------------------------------------

  # This is expanded during normalization.
  def insert_twice(example_name),
    do: {:__flatten, [previously(insert: example_name), params_like(example_name)]}

end
