defmodule PokebboWeb.Rooms.Index do
  use PokebboWeb, :live_view

  alias Pokebbo.Rooms.Registry

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(
        Pokebbo.PubSub,
        "rooms"
      )
    end

    {:ok,
     assign(socket,
       rooms: Registry.list_rooms(),
       player_id: session["player_id"],
       player_username: session["player_username"]
     )}
  end

  @impl true
  def handle_event("create_room", %{"name" => name}, socket) do
    name = String.trim(name)

    if name != "" do
      Registry.create_room(name)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info(:rooms_updated, socket) do
    {:noreply,
     assign(socket,
       rooms: Registry.list_rooms()
     )}
  end
end
