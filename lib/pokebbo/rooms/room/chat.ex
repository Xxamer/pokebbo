defmodule Pokebbo.Rooms.Room.Chat do
  def new_message(player, content) do
    %{
      id: System.unique_integer([:positive]),
      player_id: player.id,
      username: player.username,
      content: content
    }
  end
end
