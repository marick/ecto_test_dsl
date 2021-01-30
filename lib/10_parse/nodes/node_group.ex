defmodule EctoTestDSL.Parse.Node.Group do
  use EctoTestDSL.Drink.Me
#  use T.Drink.AssertionJuice
  alias T.Parse.Node

  def handle_eens(example, default_module) do
    new_example = update_eenable(example, default_module)
    eens = Enum.concat([Node.EENable.eens(new_example.setup_instructions),
                        Node.EENable.eens(new_example.params)])

    Map.put(new_example, :eens, eens)
  end


  defp update_eenable(example, default_module) do
    keys = [:setup_instructions, :params]
    
    ensure_eens = &(Node.EENable.ensure_eens(&1, default_module))
    reducer = fn key, acc ->
      Map.update!(acc, key, ensure_eens)
    end

    keys
    |> Enum.reduce(example, reducer)
  end

  def accumulated_eens(example) do 
    keys = [:setup_instructions, :params]

    getter = fn key -> 
      Map.get(example, key) |> Node.EENable.eens
    end

    Enum.flat_map(keys, getter)
  end
end


