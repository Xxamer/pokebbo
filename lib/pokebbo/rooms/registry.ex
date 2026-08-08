defmodule Pokebbo.Rooms.Registry do
  use GenServer

  alias Pokebbo.Rooms.Room
  alias Pokebbo.Rooms.RoomSupervisor

  ## Client

  def start_link(opts \\ []) do
    GenServer.start_link(
      __MODULE__,
      %{},
      Keyword.put(opts, :name, __MODULE__)
    )
  end

  def create_room(name) do
    GenServer.call(__MODULE__, {:create_room, name})
  end

  def list_rooms do
    GenServer.call(__MODULE__, :list_rooms)
  end

  def room(id) do
    GenServer.call(__MODULE__, {:room, id})
  end

  def room_pid(id) do
    GenServer.call(__MODULE__, {:room_pid, id})
  end

  ## Server

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:create_room, name}, _from, state) do
    id = System.unique_integer([:positive])

    {:ok, pid} =
      DynamicSupervisor.start_child(
        RoomSupervisor,
        {Room, %{id: id, name: name}}
      )

    new_state = Map.put(state, id, pid)

    Phoenix.PubSub.broadcast(
      Pokebbo.PubSub,
      "rooms",
      :rooms_updated
    )

    {:reply, id, new_state}
  end

  @impl true
  def handle_call(:list_rooms, _from, state) do
    rooms =
      state
      |> Map.values()
      |> Enum.filter(&Process.alive?/1)
      |> Enum.map(&Room.state/1)

    {:reply, rooms, state}
  end

  @impl true
  def handle_call({:room, id}, _from, state) do
    case Map.get(state, id) do
      nil ->
        {:reply, :error, state}

      pid ->
        if Process.alive?(pid) do
          {:reply, {:ok, Room.state(pid)}, state}
        else
          {:reply, :error, Map.delete(state, id)}
        end
    end
  end

  @impl true
  def handle_call({:room_pid, id}, _from, state) do
    case Map.get(state, id) do
      nil ->
        {:reply, nil, state}

      pid ->
        if Process.alive?(pid) do
          {:reply, pid, state}
        else
          new_state = Map.delete(state, id)

          {:reply, nil, new_state}
        end
    end
  end
end
