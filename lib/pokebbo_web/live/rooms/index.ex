defmodule PokebboWeb.Rooms.Index do
  use PokebboWeb, :live_view
  alias Phoenix.PubSub
  alias Pokebbo.Rooms.Registry

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(Pokebbo.PubSub, "rooms")
    end

    {:ok,
     assign(socket,
       rooms: Registry.list_rooms()
     )}
  end

  @impl true
  def handle_event("create_room", %{"name" => name}, socket) do
    name = String.trim(name)

    if name != "" do
      Registry.create_room(name)
    end

    {:noreply,
     assign(socket,
       rooms: Registry.list_rooms()
     )}
  end

  @impl true
  def handle_event("join_room", %{"room-id" => room_id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/rooms/#{room_id}")}
  end

  def handle_event("join_room", unsigned_params, socket) do
  end

  #  Event from pub sub
  @impl true
  def handle_info(:rooms_updated, socket) do
    {:noreply,
     assign(socket,
       rooms: Registry.list_rooms()
     )}
  end
end
