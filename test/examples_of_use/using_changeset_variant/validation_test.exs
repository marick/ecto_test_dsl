defmodule App.Schemas.Basic.ValidationTest do
  use TransformerTestSupport.Case
  alias Definitions.Changeset.Validation, as: Params

  describe "first version" do 
    test "valid dates are accepted" do
      Params.accept_exemplar(:ok)
      |> assert_valid
      |> assert_changes(lock_version: 1,
      date: ~D[2001-01-01])
    end
    
    test "invalid dates are rejected" do
      Params.accept_exemplar(:error)
      |> assert_invalid
      |> assert_error(date: "is invalid")
    end
  end

  describe "second version" do 
    test "valid dates are accepted" do
      Params.accept_exemplar(:ok)
      |> assert_valid
      |> assert_changes(lock_version: 1,
      date: ~D[2001-01-01])
    end
    
    test "invalid dates are rejected" do
      Params.accept_exemplar(:error)
      |> assert_invalid
      |> assert_error(date: "is invalid")
    end
  end
  
end
