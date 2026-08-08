defmodule Pokebbo.Rooms.RoomSupervisor do
  use DynamicSupervisor

  def start_link(opts \\ []) do
    DynamicSupervisor.start_link(
      __MODULE__,
      :ok,
      Keyword.put(opts, :name, __MODULE__)
    )
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
