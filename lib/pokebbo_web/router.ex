defmodule PokebboWeb.Router do
  alias PokebboWeb.Rooms
  use PokebboWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PokebboWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PokebboWeb do
    pipe_through :browser
    get "/", PageController, :home
    post "/player", PlayerController, :create
  end

  scope "/rooms" do
    pipe_through :browser
    live "/", Rooms.Index, :index
    live "/:id", Rooms.Room.Index, :live
  end

  if Application.compile_env(:pokebbo, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PokebboWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
