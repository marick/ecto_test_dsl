defmodule TransformerTestSupport.DidYouMeanTest do
  use TransformerTestSupport.Case
  import TransformerTestSupport.DidYouMean

  test "find the closest" do
    assert {_, "foo"} = best_candidate("fo", ["oo", "foo", "bar"])
    assert {0.0, ""} = best_candidate("foo", [])
    assert {0.0, ""} = best_candidate("message", ["unicorn"])
  end


  test "How they print" do
    assert did_you_mean("fo", ["oo", "foo", "bar"]) ==
           "  :fo (Did you mean `:foo`?)\n"
     
    assert did_you_mean("foo", ["bar"]) ==
           "  :foo\n"
  end
end

