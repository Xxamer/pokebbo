defmodule Pokebbo.Rooms.RoomServer do
  use GenServer

  ## Client

  def start_link(room) do
    GenServer.start_link(__MODULE__, room)
  end

  def state(pid) do
    GenServer.call(pid, :state)
end


  @impl true
  def init(room) do
    {:ok,
     Map.merge(room, %{
       players: %{},
       messages: [],
     })}
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end
end
