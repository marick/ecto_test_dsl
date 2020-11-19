defmodule TransformerTestSupport.RunningExample.TraceServer do
  use GenServer

  @init %{
    leader: [],
    emitting?: false
  }

  def start(),
    do: GenServer.start_link(__MODULE__, @init, name: __MODULE__)

  def nested(f) do
    push_indent()
    try do
      result = f.()
      pop_indent()
      result
    rescue
      ex in ExUnit.AssertionError ->
        pop_indent()
        reraise ex, __STACKTRACE__
    end
  end

  def accept(report) do
    indented(report) |> emit
  end

  def add_vertical_separation do
    if at_top_level?(), do: emit ""
  end

  def at_top_level?, do: leader() == []

  def emit(iodata) do
    if emitting?(), do: IO.puts(iodata)
  end

  # ----------------------------------------------------------------------------

  # Public for testing
  def indented(report) when is_binary(report) do
    [leader(),
     String.split(report, "\n")
     |> Enum.intersperse(["\n", leader()])
    ]
  end

  def indented(report) when is_list(report) do
    [leader(), report]
  end

  # ----------------------------------------------------------------------------

  defp push_indent, do: GenServer.call(__MODULE__, :push_indent)
  defp pop_indent, do: GenServer.call(__MODULE__, :pop_indent)
  defp leader, do: GenServer.call(__MODULE__, :leader)
  defp emitting?, do: GenServer.call(__MODULE__, :emitting?)

  
  # ---------------------------SERVER SIDE--------------------------------------
  # ----------------------------------------------------------------------------

  @indent "  "

  @impl GenServer
  def init(init_arg), do: {:ok, init_arg}

  @impl GenServer
  def handle_call(:leader, _from, state) do
    {:reply, state.leader, state}
  end

  @impl GenServer
  def handle_call(:emitting?, _from, state) do
    {:reply, state.emitting?, state}
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
