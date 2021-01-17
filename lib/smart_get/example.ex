defmodule TransformerTestSupport.SmartGet.Example do
  use TransformerTestSupport.Drink.Me
  use T.Drink.AssertionJuice
  
  @moduledoc """
  """

  def metadata!(example, field),
    do: Map.fetch!(example.metadata, field)

  def metadata(example, field),
    do: Map.get(example.metadata, field)

  def step_functions(example), do: metadata!(example, :steps)
  def module_under_test(example), do: metadata!(example, :module_under_test)
  def format(example), do: metadata!(example, :format)
  def name(example), do: metadata!(example, :name)
  def workflows(example), do: metadata!(example, :workflows)
  def workflow_name(example), do: metadata!(example, :workflow_name)
  def field_transformations(example), do: metadata!(example, :field_transformations)
  def previously(example), do: metadata!(example, :previously)
  def examples_module(example), do: metadata!(example, :examples_module)


  def repo(example), do: metadata(example, :repo)
  

end
