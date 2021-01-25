defmodule EctoTestDSL.TestDataServer do
  use GenServer

  def start(),
    do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  @doc """
  Lazy getter that triggers the creation of the data contained in `test_data_module`.
  """
  def test_data(test_data_module) do
    GenServer.call(__MODULE__, {:test_data, test_data_module})
  end

  def put_value_into(value, test_data_module) do
    GenServer.call(__MODULE__, {:put, test_data_module, value})
  end
  

  # ----------------------------------------------------------------------------

  @impl GenServer
  def init(init_arg), do: {:ok, init_arg}

  @impl GenServer
  def handle_call({:put, test_data_module, value}, _from, state) do
    new_state = Map.put(state, test_data_module, value)
    {:reply, new_state, new_state}
  end

  @impl GenServer
  def handle_call({:test_data, test_data_module}, _from, state) do
    alias EctoTestDSL.Parse.TopLevel
    
    case Map.get(state, test_data_module) do
      nil ->
        test_data =
          test_data_module.create_test_data()
          |> TopLevel.propagate_metadata 
        {:reply, test_data, Map.put(state, test_data_module, test_data)}
      test_data ->
        {:reply, test_data, state}
    end
  end
end
