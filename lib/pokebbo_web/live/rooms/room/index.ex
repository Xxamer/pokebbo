defmodule PokebboWeb.Rooms.Room.Index do
  use PokebboWeb, :live_view

  alias Pokebbo.Rooms.Registry
  alias Pokebbo.Rooms.Room
  alias Pokebbo.Rooms.Room.Player

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    room_id = String.to_integer(id)

    case Registry.room_pid(room_id) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Room not found")
         |> push_navigate(to: ~p"/rooms")}

      room_pid ->
        player = build_player(socket)
        room = Room.join(room_pid, player)
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
           room: room
         )}
    end
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

  @impl true
  def handle_info({:new_message, message}, socket) do
    socket =
      update(socket, :room, fn room ->
        %{room | messages: room.messages ++ [message]}
      end)

    {:noreply, socket}
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

  defp build_player(_socket) do
    %Player{
      id: 1234,
      username: "Not christian",
      x: 100,
      y: 100,
      direction: :down
    }
  end
end
