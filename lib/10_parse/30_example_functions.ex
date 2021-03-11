defmodule EctoTestDSL.Parse.ExampleFunctions do
  use EctoTestDSL.Drink.Me
  use T.Drink.AndParse
  use EctoTestDSL.Drink.Assertively

  @moduledoc """
  There are three special categories of example-level commands, as reflected
  in their names:

  `*_of` functions record the intention to derefence an EEN a test-run time and
  replace the "of" value with a field from the persistent value.__struct__

       id_of(een)

  `*_from` are like `of` functions, but they substitute many fields. They
  are used for things like having one `Repo.insert` create not just a single
  primary value but also other associated values (belongs_to, etc.)

       params_from(een, except: ...)

  `*_like` functions are akin to uses of macros. They are expanded to include
  the params (and only the params) from an example defined in the same module.

       params_like(:example_name)

  """

  # ----------------------------------------------------------------------------
  def params(opts \\ []),
    do: {:params, Pnode.Params.parse(opts)}
  
  def params_like(example_name, opts),
    do: {:params, Pnode.ParamsLike.parse(example_name, opts)}
  def params_like(example_name), 
    do: params_like(example_name, except: [])

  def params_from(een, opts),
    do: {:params, Pnode.ParamsFrom.parse(een, opts)}
  def params_from(een),
    do: params_from(een, except: [])
    

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

  # ----------------------------------------------------------------------------

  # This is expanded during normalization.
  def insert_twice(example_name),
    do: {:__flatten, [previously(insert: example_name), params_like(example_name)]}

end
