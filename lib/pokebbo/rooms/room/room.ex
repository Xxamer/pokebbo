defmodule Pokebbo.Rooms.Room do
  use GenServer

  ## Client

  def start_link(room) do
    GenServer.start_link(__MODULE__, room)
  end

  def state(pid) do
    GenServer.call(pid, :state)
  end

  def join(pid, player) do
    GenServer.call(pid, {:join, player})
  end

  def leave(pid, player_id) do
    GenServer.call(pid, {:leave, player_id})
  end

  ## Server

  @impl true
  def init(room) do
    {:ok,
     Map.merge(room, %{
       players: %{},
       messages: []
     })}
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:join, player}, _from, state) do
    new_state =
      update_in(state.players, fn players ->
        Map.put(players, player.id, player)
      end)

    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call({:leave, player_id}, _from, state) do
    new_state =
      update_in(state.players, fn players ->
        Map.delete(players, player_id)
      end)

    {:reply, :ok, new_state}
  end
end
