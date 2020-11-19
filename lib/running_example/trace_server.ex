defmodule TransformerTestSupport.RunningExample.TraceServer do
  use GenServer

  @init %{
    prefix: [],
    emitting?: false,
    max_level: 9999,
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

  def at_top_level?, do: get().prefix == []

  def emit(iodata) do
    if emitting?(), do: IO.puts(iodata)
  end

  defp emitting?() do
    control = get()
    control.emitting? && length(control.prefix) < control.max_level
  end

  def update(opts) do
    new_val = Enum.into(opts, @init)
    GenServer.call(__MODULE__, {:set, new_val})
  end

  def reset,
    do: GenServer.call(__MODULE__, {:set, @init})

  # ----------------------------------------------------------------------------

  # Public for testing
  def indented(report) when is_binary(report) do
    [prefix(),
     String.split(report, "\n")
     |> Enum.intersperse(["\n", prefix()])
    ]
  end

  def indented(report) when is_list(report) do
    [prefix(), report]
  end

  # ----------------------------------------------------------------------------

  defp push_indent, do: GenServer.call(__MODULE__, :push_indent)
  defp pop_indent, do: GenServer.call(__MODULE__, :pop_indent)
  defp get, do: GenServer.call(__MODULE__, :get)

  defp prefix, do: get().prefix

  
  # ---------------------------SERVER SIDE--------------------------------------
  # ----------------------------------------------------------------------------

  @indent "  "

  @impl GenServer
  def init(init_arg), do: {:ok, init_arg}

  @impl GenServer
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @impl GenServer
  def handle_call({:set, new_state}, _from, _state) do
    {:reply, :ok, new_state}
  end

  @impl GenServer
  def handle_call(:push_indent, _from, state) do
    new_state = Map.update!(state, :prefix, &([@indent | &1]))
    {:reply, :ok, new_state}
  end

  @impl GenServer
  def handle_call(:pop_indent, _from, state) do
    new_state = Map.update!(state, :prefix, fn [_ | rest] -> rest end)
    {:reply, :ok, new_state}
  end
end
