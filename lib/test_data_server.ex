defmodule TransformerTestSupport.TestDataServer do
  use GenServer

  def start(),
    do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  @doc """
  Lazy getter that triggers the creation of the data contained in `param_module`.
  """
  def test_data(param_module) do
    GenServer.call(__MODULE__, {:test_data, param_module})
  end

  def put_value_into(value, param_module) do
    GenServer.call(__MODULE__, {:put, param_module, value})
  end

  # ----------------------------------------------------------------------------

  @impl GenServer
  def init(init_arg), do: {:ok, init_arg}

  @impl GenServer
  def handle_call({:put, param_module, value}, _from, state) do
    new_state = Map.put(state, param_module, value)
    {:reply, new_state, new_state}
  end

  @impl GenServer
  def handle_call({:test_data, param_module}, _from, state) do
    alias TransformerTestSupport.Parse.TopLevel
    
    case Map.get(state, param_module) do
      nil ->
        test_data =
          param_module.create_test_data()
          |> TopLevel.propagate_metadata 
        {:reply, test_data, Map.put(state, param_module, test_data)}
      test_data ->
        {:reply, test_data, state}
    end
  end
end
