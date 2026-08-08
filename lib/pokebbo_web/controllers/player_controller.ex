defmodule PokebboWeb.PlayerController do
  use PokebboWeb, :controller

  def create(conn, %{"username" => username}) do
    username = String.trim(username)

    if username == "" do
      conn
      |> put_flash(:error, "Username cannot be empty")
      |> redirect(to: ~p"/rooms")
    else
      player_id = Ecto.UUID.generate()
      conn
      |> put_session(:player_id, player_id)
      |> put_session(:player_username, username)
      |> redirect(to: ~p"/rooms")
    end
  end
end
