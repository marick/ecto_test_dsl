defmodule TransformerTestSupport.RunningExample.TraceServer do
  use GenServer

  def start(),
    do: GenServer.start_link(__MODULE__, %{leader: []}, name: __MODULE__)

  def accept(report) do
    indent(report) |> IO.puts
  end

  def nested(f) do
    push_indent
    result = f.()
    pop_indent
    result
  end

  def push_indent, do: GenServer.call(__MODULE__, :push_indent)
  def pop_indent, do: GenServer.call(__MODULE__, :pop_indent)

  def separate do
    if at_top_level?, do: IO.puts ""
  end

  defp indent(report) do
    [leader(), report]
  end

  defp at_top_level?, do: leader() == []

  defp leader, do: GenServer.call(__MODULE__, :leader)

  # ----------------------------------------------------------------------------

  @indent "  "

  @impl GenServer
  def init(init_arg), do: {:ok, init_arg}

  @impl GenServer
  def handle_call(:leader, _from, state) do
    {:reply, state.leader, state}
  end

  @impl GenServer
  def handle_call(:push_indent, _from, state) do
    new_state = Map.update!(state, :leader, &([@indent | &1]))
    {:reply, :ok, new_state}
  end

  @impl GenServer
  def handle_call(:pop_indent, _from, state) do
    new_state = Map.update!(state, :leader, fn [_ | rest] -> rest end)
    {:reply, :ok, new_state}
  end
end
