defmodule TransformerTestSupport.RunningExample.TraceServer do
  use GenServer

  @init %{
    leader: [],
    tracing: false
  }

  def start(),
    do: GenServer.start_link(__MODULE__, @init, name: __MODULE__)

  def accept(report) do
    indent(report) |> IO.puts
  end

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

  def push_indent, do: GenServer.call(__MODULE__, :push_indent)
  def pop_indent, do: GenServer.call(__MODULE__, :pop_indent)

  def separate do
    if at_top_level?(), do: IO.puts ""
  end

  def indent(report) when is_binary(report) do
    [leader(), 
     String.split(report, "\n")
     |> Enum.intersperse(["\n", leader()])
    ]
  end

  def indent(report) when is_list(report) do
    [leader(), report]
  end

  # def indent(report) when is_list(report) do
  #   for part <- report, do: [leader(), indent(part)]
  # end
  
  # def indent(report) do
  #   if String.contains?(report, "\n") do 
  #     for part <- String.split(report, "\n") do 
  #       [leader(), part, "\n"]
  #     end
  #   else
  #     [leader(), report]
  #   end
  # end

  def at_top_level?, do: leader() == []

  def leader, do: GenServer.call(__MODULE__, :leader)

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
