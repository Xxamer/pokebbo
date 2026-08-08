defmodule PokebboWeb.PageController do
  use PokebboWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
