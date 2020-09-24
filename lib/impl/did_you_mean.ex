defmodule TransformerTestSupport.Impl.DidYouMean do
  
  def did_you_mean(bad_atoms, candidates) when is_list(bad_atoms) do
    bad_strings = Enum.map(bad_atoms, &to_string/1)
    candidates = Enum.map(candidates, &to_string/1)

    Enum.map(bad_strings, &did_you_mean(&1, candidates))
  end
  
  def did_you_mean(bad_string, candidates) do
    {closest_distance, closest_key} = best_candidate(bad_string, candidates)

    comment = 
      if closest_distance > 0.5 do
        " (Did you mean `:#{closest_key}`?)"
      else
        ""
      end

    "  :#{bad_string}#{comment}\n"
  end

  def best_candidate(bad_string, candidates) do
    check_next = fn candidate, {best_distance, _best_string} = so_far ->
      distance = String.jaro_distance(bad_string, candidate)
      if distance > best_distance do
        {distance, candidate}
      else
        so_far
      end
    end
      
    Enum.reduce(candidates, {0.0, ""}, &(check_next.(&1, &2)))
  end
end
