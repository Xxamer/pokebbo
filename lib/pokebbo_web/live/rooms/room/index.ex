defmodule PokebboWeb.Rooms.Room.Index do
  use PokebboWeb, :live_view

  alias Pokebbo.Rooms.Registry
  alias Pokebbo.Rooms.Room
  alias Pokebbo.Rooms.Room.Player

  @impl true
  @impl true
  def mount(%{"id" => id}, session, socket) do
    room_id = String.to_integer(id)

    case Registry.room_pid(room_id) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Room not found")
         |> push_navigate(to: ~p"/rooms")}

      room_pid ->
        player = build_player(session)

        socket =
          assign(socket,
            room_id: room_id,
            room_pid: room_pid,
            player: player
          )

        if connected?(socket) do
          Phoenix.PubSub.subscribe(
            Pokebbo.PubSub,
            "room:#{room_id}"
          )
          # JOIN
          room = Room.join(room_pid, player)
          {:ok,
           assign(socket,
             room: room
           )}
        else
          {:ok,
           assign(socket,
             room: Room.state(room_pid)
           )}
        end
    end
  end

  # ==================================================
  # Player joined
  # ==================================================

  @impl true
  def handle_info({:player_joined, player}, socket) do
    if player.id == socket.assigns.player.id do
      {:noreply, socket}
    else
      {:noreply,
       push_event(socket, "player_joined", %{
         id: player.id,
         username: player.username,
         x: player.x,
         y: player.y,
         direction: player.direction
       })}
    end
  end

  # ==================================================
  # Player moved
  # ==================================================

  @impl true
  def handle_info(
        {:player_moved, player},
        socket
      ) do
    # No enviamos nuestro propio movimiento al mismo cliente
    if player.id == socket.assigns.player.id do
      {:noreply, socket}
    else
      {:noreply,
       push_event(
         socket,
         "player_moved",
         %{
           id: player.id,
           x: player.x,
           y: player.y,
           direction: player.direction
         }
       )}
    end
  end

  # ==================================================
  # Player left
  # ==================================================

  @impl true
  def handle_info(
        {:player_left, player_id},
        socket
      ) do
    {:noreply,
     push_event(
       socket,
       "player_left",
       %{
         id: player_id
       }
     )}
  end

  # ==================================================
  # New message
  # ==================================================

  @impl true
  def handle_info(
        {:new_message, message},
        socket
      ) do
    {:noreply,
     update(socket, :room, fn room ->
       update_in(
         room.messages,
         fn messages ->
           messages ++ [message]
         end
       )
     end)}
  end

  # ==================================================
  # Send message
  # ==================================================

  @impl true
  def handle_event(
        "send_message",
        %{"message" => message},
        socket
      ) do
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

  # ==================================================
  # Player movement
  # ==================================================

  @impl true
  def handle_event(
        "player_move",
        %{
          "x" => x,
          "y" => y,
          "direction" => direction
        },
        socket
      ) do
    x = parse_number(x)
    y = parse_number(y)
    direction = parse_direction(direction)

    Room.move_player(
      socket.assigns.room_pid,
      socket.assigns.player.id,
      x,
      y,
      direction
    )

    {:noreply, socket}
  end

  # ==================================================
  # Terminate
  # ==================================================

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

  # ==================================================
  # Need this becasue pixiJS load after the server, guess this is good
  # ==================================================
  @impl true
  def handle_event("request_initial_players", _params, socket) do
    room = Room.state(socket.assigns.room_pid)

    players =
      room.players
      |> Map.values()
      |> Enum.reject(fn player ->
        player.id == socket.assigns.player.id
      end)
      |> Enum.map(fn player ->
        %{
          id: player.id,
          username: player.username,
          x: player.x,
          y: player.y,
          direction: player.direction
        }
      end)

    {:noreply,
     push_event(socket, "initial_players", %{
       players: players
     })}
  end

  # ==================================================
  # Private
  # ==================================================

  defp build_player(session) do
    %Player{
      id: session["player_id"],
      username: session["player_username"],
      x: 100,
      y: 100,
      direction: :down
    }
  end

  # ==================================================
  # Parse number
  # ==================================================

  defp parse_number(value) when is_integer(value), do: value
  defp parse_number(value) when is_float(value), do: value

  defp parse_number(value) when is_binary(value) do
    case Float.parse(value) do
      {number, _} ->
        number

      :error ->
        0
    end
  end

  # ==================================================
  # Parse direction
  # ==================================================

  defp parse_direction("down"), do: :down
  defp parse_direction("down-right"), do: :"down-right"
  defp parse_direction("right"), do: :right
  defp parse_direction("up-right"), do: :"up-right"
  defp parse_direction("up"), do: :up
  defp parse_direction("up-left"), do: :"up-left"
  defp parse_direction("left"), do: :left
  defp parse_direction("down-left"), do: :"down-left"
  defp parse_direction(_), do: :down
end
