defmodule TransformerTestSupport.TestBuild do
  import TransformerTestSupport.Build
  alias TransformerTestSupport.TestDataServer

  def one_category(category_opts), do: one_category([], category_opts)

  def one_category(category_name \\ :category_name, start_opts, category_opts) do
    start(start_opts)
    |> category(category_name, category_opts)
    |> propagate_metadata
  end

  def with_params(example_name, params) do
    one_category([{example_name, [params: params]}])
  end


  # Avoid the rigamarole of a whole Variant module.
  def stash(test_data, module),
    do: TestDataServer.put_value_into(test_data, module)
  
end
