defmodule SmartGet.ChangesetChecks.ConstraintTest do
  use TransformerTestSupport.Drink.Me
  use T.Case
  alias T.SmartGet.ChangesetChecks, as: Checks
  import T.Build
  alias Template.Dynamic

  defmodule Examples do 
    use Template.Trivial
  end
  
  # These are kind of dumb tests, but the code is pretty uncomplicated.
  test "fetching constraint checks from an example" do
    expect = fn example_data, expected ->
      Dynamic.example(Examples, example_data)
      |> Checks.get_constraint_checks
      |> assert_equal(expected)
    end
    
                          [   ]
               |> expect.([   ])
    [constraint_changeset(changes: [name: "bossie"])]
               |> expect.(changes: [name: "bossie"])
  end
end
