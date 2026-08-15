defmodule PokebboWeb.Rooms.Room.Index do
  use PokebboWeb, :live_view

  alias Pokebbo.Rooms.Registry
  alias Pokebbo.Rooms.Room
  alias Pokebbo.Rooms.Room.Player

  @impl true
  def mount(%{"id" => id}, session, socket) do
    IO.inspect(session, label: "ROOM SESSION WORK FFS")
    room_id = String.to_integer(id)

    case Registry.room_pid(room_id) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Room not found")
         |> push_navigate(to: ~p"/rooms")}
      room_pid ->
        player = build_player(session)
        Room.join(room_pid, player)
        if connected?(socket) do
          Phoenix.PubSub.subscribe(
            Pokebbo.PubSub,
            "room:#{room_id}"
          )
        end
        {:ok,
         assign(socket,
           room_id: room_id,
           room_pid: room_pid,
           player: player,
           room: Room.state(room_pid)
         )}
    end
  end

  @impl true
  def terminate(_reason, socket) do
    if connected?(socket) &&
         Map.has_key?(socket.assigns, :player) &&
         Map.has_key?(socket.assigns, :room_pid) do
      Room.leave(
        socket.assigns.room_pid,
        socket.assigns.player.id
      )
    end

    :ok
  end
  @impl true
  def handle_info(
        {:player_joined, player},
        socket
      ) do
    if player.id == socket.assigns.player.id do
      {:noreply, socket}
    else
      {:noreply,
       push_event(
         socket,
         "player_joined",
         %{
           id: player.id,
           username: player.username,
           x: player.x,
           y: player.y,
           direction: player.direction
         }
       )}
    end
  end

  @impl true
  def handle_info({:player_left, player_id}, socket) do
    {:noreply,
     push_event(
       socket,
       "player_left",
       %{
         id: player_id
       }
     )}
  end

  @impl true
  def handle_info({:new_message, message}, socket) do
    {:noreply,
     update(socket, :room, fn room ->
       update_in(room.messages, fn messages ->
         messages ++ [message]
       end)
     end)}
  end

  @impl true
  def handle_event("send_message", %{"message" => message}, socket) do
    message = String.trim(message)
    if message == "" do
      {:noreply, socket}
    else
      Room.send_message(
        socket.assigns.room_pid,
        socket.assigns.player,
        message
      )
      {:noreply, socket}
    end
  end

  #  Private
  defp build_player(session) do
    %Player{
      id: session["player_id"],
      username: session["player_username"],
      x: 100,
      y: 100,
      direction: :down
    }
  end
end
