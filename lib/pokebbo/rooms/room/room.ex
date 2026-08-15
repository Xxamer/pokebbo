defmodule Pokebbo.Rooms.Room do
  use GenServer
  alias Pokebbo.Rooms.Room.Chat
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

  def send_message(pid, player, message) do
    GenServer.call(pid, {:send_message, player, message})
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

    broadcast(
      state.id,
      {:player_joined, player}
    )

    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:leave, player_id}, _from, state) do
    new_state =
      update_in(state.players, fn players ->
        Map.delete(players, player_id)
      end)

    broadcast(
      state.id,
      {:player_left, player_id}
    )

    {:reply, :ok, new_state}
  end

  def handle_call({:send_message, player, content}, _from, state) do
    message = Chat.new_message(player, content)

    new_state =
      update_in(state.messages, fn messages ->
        messages ++ [message]
      end)
    Phoenix.PubSub.broadcast(
      Pokebbo.PubSub,
      "room:#{state.id}",
      {:new_message, message}
    )
    {:reply, new_state, new_state}
  end

  ## Private
  defp broadcast(room_id, message) do
    Phoenix.PubSub.broadcast(
      Pokebbo.PubSub,
      "room:#{room_id}",
      message
    )
  end
end
