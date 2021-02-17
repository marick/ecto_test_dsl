defmodule EctoTestDSL.Parse.ExampleFunctions do
  use EctoTestDSL.Drink.Me
  use T.Drink.AndParse
  use EctoTestDSL.Drink.AssertionJuice

  # ----------------------------------------------------------------------------
  def params(opts \\ []),
    do: {:params, Pnode.Params.parse(opts)}
  
  def params_like(example_name, opts),
    do: {:params, Pnode.ParamsLike.parse(example_name, opts)}
  def params_like(example_name), 
    do: params_like(example_name, except: [])

  def params_from_repo(een, opts),
    do: {:params, Pnode.ParamsFromRepo.parse(een, opts)}
  def params_from_repo(een),
    do: params_from_repo(een, except: [])
    

  # ----------------------------------------------------------------------------
  
  def previously(opts), 
    do: {:previously, Pnode.Previously.parse(opts)}

  def changeset(opts),
    do: {:validation_changeset_checks, Pnode.ChangesetChecks.parse(opts)}
  def constraint_changeset(opts),
    do: {:constraint_changeset_checks, Pnode.ChangesetChecks.parse(opts)}

  def fields(opts), do: {:field_checks, Pnode.Fields.parse(opts)}

  def fields_like(een_or_name, opts \\ []),
    do: {:fields_like, Pnode.FieldsLike.parse(een_or_name, opts)}

  def params_from_selecting(een, _opts \\ [except: []]) do
    {:params_from_selecting, een}
  end
  

  # ----------------------------------------------------------------------------

  # This is expanded during normalization.
  def insert_twice(example_name),
    do: {:__flatten, [previously(insert: example_name), params_like(example_name)]}

end
