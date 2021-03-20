defmodule Parse.SequencesTest do
  use EctoTestDSL.Case
  use T.Drink.AndParse
  use Template.Trivial
  alias Parse.Sequences.Util

  defmodule Examples do
    use Template.Trivial
  end

  defmodule Schema do 
  end

  setup do
    Examples.started(examples_module: Examples, module_under_test: Schema)
    :ok
  end

  def expect(actual, expected) do
    assert_equal(actual, Util.sequence(expected))
  end

  test "insert_twice" do
    expect(
      insert_twice(:name), [
        previously(insert: een(name: Examples)),
        params_like(:name)
      ])
  end

  @tag :skip
  test "blanks" do
    blank="can't be blank"
    
    expect(
      blanks([:a, :b]), [
        params(a: "", b: ""),
        changeset: [errors: [a: blank, b: blank]]
      ])
  end
end
